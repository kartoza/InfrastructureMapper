#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Create or update a persistent PostgreSQL database at your chosen CRS.
#
# The one command for "load this schema for the first time" and "git
# pull'd some new domains/migrations, bring my database up to date" —
# idempotent either way.
#
# Workflow:
#   1. Resolve CRS (--crs flag > remembered .im-crs > interactive prompt).
#   2. Regenerate the CRS-templated model/migration SQL via
#      scripts/generate_models.py (build/models/sql/...).
#   3. createdb if the target does not exist yet.
#   4. If the target has no schema_migrations row yet, bootstrap it from the
#      templated baseline + fixtures, stamped as "v0.0.0" (pre-migration) so
#      step 5 still applies every migration above it, CRS-correct.
#   5. Delegate to scripts/migrate_pg.sh for anything pending, pointed at
#      the templated migrations directory.
#
# Run inside 'nix develop'. Postgres must be running on $PGHOST:$PGPORT.
#
# Usage:
#   scripts/apply_pg.sh [--crs EPSG:NNNN] <dbname>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"
# shellcheck source=scripts/lib/crs.sh
source "$SCRIPT_DIR/lib/crs.sh"

CRS_FLAG=""
DBNAME=""
while [ $# -gt 0 ]; do
    case "$1" in
        --crs) CRS_FLAG="$2"; shift 2 ;;
        --crs=*) CRS_FLAG="${1#--crs=}"; shift ;;
        -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
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

bash "$SCRIPT_DIR/ensure_pg.sh"

crs_resolve "$CRS_FLAG"

echo ">> Regenerating CRS-templated models at $CRS_EPSG..."
python3 "$SCRIPT_DIR/generate_models.py" --crs "$CRS_EPSG" >/dev/null

MODELS="$ROOT/build/models/sql"
PSQL=(psql -h "$PGHOST" -p "$PGPORT" -d "$DBNAME" -v ON_ERROR_STOP=1 -q)

if ! psql -h "$PGHOST" -p "$PGPORT" -d postgres -tAc \
    "SELECT 1 FROM pg_database WHERE datname = '$DBNAME'" | grep -q 1; then
    echo ">> Creating database '$DBNAME'..."
    createdb -h "$PGHOST" -p "$PGPORT" "$DBNAME"
fi

EXISTING_VERSION="$(
    psql -h "$PGHOST" -p "$PGPORT" -d "$DBNAME" -v ON_ERROR_STOP=1 -At \
        -c 'SELECT version FROM current_schema_version;' 2>/dev/null || true
)"

if [ -z "$EXISTING_VERSION" ]; then
    echo ">> No baseline found on '$DBNAME' — bootstrapping at $CRS_EPSG..."

    BASELINE_FILES=(
        0-meta.sql
        1-infrastructure.sql
        2-electricity.sql
        3-water.sql
        4-vegetation.sql
        5-monitoring.sql
        6-buildings.sql
        7-fencing.sql
        8-poi.sql
        9-landuse.sql
        10-gates.sql
        11-poles.sql
        12-culinary.sql
        13-roads.sql
    )

    echo ">> Enabling PostGIS..."
    "${PSQL[@]}" -f sql/extensions.sql

    echo ">> Applying CRS-templated baseline schema..."
    for f in "${BASELINE_FILES[@]}"; do
        echo "   $f"
        "${PSQL[@]}" -f "$MODELS/$f"
    done

    echo ">> Applying CRS-templated fixtures..."
    "${PSQL[@]}" -f "$MODELS/fixtures.sql"

    # Stamp as the pre-migration baseline (not the current released VERSION)
    # so migrate_pg.sh below still treats every released migration as
    # pending — that's what actually brings e.g. roads/intersection onto
    # the chosen CRS.
    BASELINE_CHECKSUM=$(
        (for f in "${BASELINE_FILES[@]}"; do cat "$MODELS/$f"; done; cat "$MODELS/fixtures.sql") \
            | sha256sum | awk '{print $1}'
    )
    "${PSQL[@]}" -c "
INSERT INTO schema_migrations
    (version, major, minor, patch, applied_by, checksum, is_baseline, notes)
VALUES
    ('v0.0.0', 0, 0, 0, 'apply_pg.sh', '$BASELINE_CHECKSUM', TRUE, 'Initial baseline')
ON CONFLICT (version) DO NOTHING;
"
else
    echo ">> Existing schema version on '$DBNAME': $EXISTING_VERSION"
fi

echo ">> Applying any pending migrations..."
bash "$SCRIPT_DIR/migrate_pg.sh" "$DBNAME" --migrations-dir "$MODELS/migrations/pg"

FINAL="$("${PSQL[@]}" -At -c 'SELECT version FROM current_schema_version;')"
echo ""
echo ">> Done. '$DBNAME' is at $FINAL, CRS $CRS_EPSG."
