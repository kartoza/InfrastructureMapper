#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Apply pending PostgreSQL schema migrations to a target database.
#
# Strict sequential semantics: reads current_schema_version from the target,
# then applies every sql/migrations/pg/vX.Y.Z.sql whose version is greater,
# in semver order, each in its own transaction. Each successful migration
# records itself in the schema_migrations table.
#
# Usage:
#   scripts/migrate_pg.sh [options] <dbname>
#
# Options:
#   --dry-run               Show the plan, do not apply.
#   --target vX.Y.Z         Stop after this version (default: latest available).
#   --crs EPSG:NNNN         Also reproject all spatial columns to this CRS.

set -euo pipefail

DBNAME=""
DRYRUN=0
TARGET=""
CRS=""

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRYRUN=1; shift ;;
        --target) TARGET="$2"; shift 2 ;;
        --target=*) TARGET="${1#--target=}"; shift ;;
        --crs) CRS="$2"; shift 2 ;;
        --crs=*) CRS="${1#--crs=}"; shift ;;
        -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
        -*) echo "Unknown option: $1" >&2; exit 2 ;;
        *)
            if [ -z "$DBNAME" ]; then DBNAME="$1"; else
                echo "ERROR: extra positional argument '$1'" >&2; exit 2
            fi
            shift
            ;;
    esac
done

[ -n "$DBNAME" ] || { echo "ERROR: <dbname> required. See --help." >&2; exit 2; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PGHOST="${PGHOST:-$ROOT/pgdata}"
PGPORT="${PGPORT:-5432}"

PSQL=(psql -h "$PGHOST" -p "$PGPORT" -d "$DBNAME" -v ON_ERROR_STOP=1 -At)

# Strip "v" prefix and normalise.
strip_v() { echo "${1#v}"; }

# Returns 0 (true) if $1 > $2 in semver terms.
semver_gt() {
    local a b
    IFS='.' read -ra a <<< "$(strip_v "$1")"
    IFS='.' read -ra b <<< "$(strip_v "$2")"
    for i in 0 1 2; do
        if [ "${a[$i]:-0}" -gt "${b[$i]:-0}" ]; then return 0; fi
        if [ "${a[$i]:-0}" -lt "${b[$i]:-0}" ]; then return 1; fi
    done
    return 1
}

CUR_VERSION="$("${PSQL[@]}" -c 'SELECT version FROM current_schema_version;' 2>/dev/null || true)"
if [ -z "$CUR_VERSION" ]; then
    echo "ERROR: target database has no current_schema_version view." >&2
    echo "       Is '$DBNAME' built from this project's baseline?" >&2
    exit 1
fi
echo ">> Current schema version on '$DBNAME': $CUR_VERSION"

# Discover candidate migrations, sorted by semver.
shopt -s nullglob
PENDING_FILES=()
PENDING_VERS=()
for f in "$ROOT"/sql/migrations/pg/v[0-9]*.sql; do
    base="$(basename "$f")"
    ver="${base%.sql}"
    if semver_gt "$ver" "$CUR_VERSION"; then
        if [ -n "$TARGET" ] && semver_gt "$ver" "$TARGET"; then
            continue
        fi
        PENDING_FILES+=("$f")
        PENDING_VERS+=("$ver")
    fi
done

# Sort the parallel arrays by semver of the version label.
if [ "${#PENDING_VERS[@]}" -gt 0 ]; then
    paired=()
    for i in "${!PENDING_VERS[@]}"; do
        paired+=("${PENDING_VERS[$i]}|${PENDING_FILES[$i]}")
    done
    mapfile -t sorted < <(printf '%s\n' "${paired[@]}" | sort -V)
    PENDING_VERS=()
    PENDING_FILES=()
    for entry in "${sorted[@]}"; do
        PENDING_VERS+=("${entry%%|*}")
        PENDING_FILES+=("${entry##*|}")
    done
fi

if [ "${#PENDING_VERS[@]}" -eq 0 ]; then
    echo ">> Already at the requested version. Nothing to do."
    exit 0
fi

echo ">> Will apply ${#PENDING_VERS[@]} migration(s) in order:"
for v in "${PENDING_VERS[@]}"; do echo "   $v"; done

if [ "$DRYRUN" = 1 ]; then
    echo ">> --dry-run; no changes applied."
    exit 0
fi

APPLIED_BY="${USER:-$(whoami)}@migrate_pg.sh"

for i in "${!PENDING_VERS[@]}"; do
    ver="${PENDING_VERS[$i]}"
    file="${PENDING_FILES[$i]}"
    vnum="$(strip_v "$ver")"
    IFS='.' read -r maj min pat <<< "$vnum"
    checksum="$(sha256sum "$file" | awk '{print $1}')"
    echo ">> Applying $ver ($file)..."
    # Wrap migration + bookkeeping in a single transaction.
    {
        echo "BEGIN;"
        cat "$file"
        echo ""
        cat <<EOSQL
INSERT INTO schema_migrations
    (version, major, minor, patch, applied_by, checksum, is_baseline, notes)
VALUES
    ('$ver', $maj, $min, $pat, '$APPLIED_BY', '$checksum', FALSE, NULL)
ON CONFLICT (version) DO NOTHING;
COMMIT;
EOSQL
    } | "${PSQL[@]}"
done

# Optional reprojection after all schema changes have landed.
if [ -n "$CRS" ]; then
    case "$CRS" in
        EPSG:[0-9]*) SRID="${CRS#EPSG:}" ;;
        [0-9]*)      SRID="$CRS" ;;
        *) echo "ERROR: --crs must be like 'EPSG:3857' or '3857'." >&2; exit 2 ;;
    esac
    if [ "$SRID" = "4326" ]; then
        echo "⚠️  WARNING: EPSG:4326 is geographic; ~2 m accuracy." >&2
    fi
    echo ">> Reprojecting all spatial columns to EPSG:$SRID..."
    "${PSQL[@]}" <<SQL
DO \$\$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT f_table_schema AS sch, f_table_name AS tbl, f_geometry_column AS col, type AS gtype
        FROM geometry_columns WHERE f_table_schema = 'public'
    LOOP
        EXECUTE format(
            'ALTER TABLE %I.%I ALTER COLUMN %I TYPE GEOMETRY(%s, $SRID) USING ST_Transform(%I, $SRID)',
            rec.sch, rec.tbl, rec.col, rec.gtype, rec.col
        );
        RAISE NOTICE 'Reprojected %.%.% -> EPSG:$SRID', rec.sch, rec.tbl, rec.col;
    END LOOP;
END
\$\$;
SQL
fi

FINAL="$("${PSQL[@]}" -c 'SELECT version FROM current_schema_version;')"
echo ">> Done. Current schema version on '$DBNAME': $FINAL"
