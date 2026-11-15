#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Build a fresh GeoPackage from the canonical Postgres schema.
#
# Workflow:
#   1. Drop/recreate a throwaway PG database.
#   2. Apply baseline schema + fixtures + frozen PG migrations + UNRELEASED.sql.
#   3. Reproject all spatial columns to the resolved CRS.
#   4. Stamp the result with the current VERSION.
#   5. Export to GeoPackage via ogr2ogr.
#   6. Post-process for GPKG-specific bits (view, etc.).
#   7. Register GeoPackage Related Tables Extension relations (sql/gpkg_relations.sql).
#   8. Clean up.
#
# Run inside 'nix develop'. Postgres must be running on $PGHOST:$PGPORT.
#
# Usage:
#   scripts/build_gpkg.sh [--crs EPSG:NNNN]
#
# CRS is resolved as: --crs flag > CRS remembered in .im-crs (see
# scripts/generate_models.py) > interactive prompt. EPSG:4326 is geographic
# and accurate only to ~2 m; pick a metric CRS (UTM zone, etc.) for field
# work that needs precise distances or areas.

set -euo pipefail

CRS_FLAG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --crs) CRS_FLAG="$2"; shift 2 ;;
        --crs=*) CRS_FLAG="${1#--crs=}"; shift ;;
        -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck source=scripts/lib/crs.sh
source "$ROOT/scripts/lib/crs.sh"
crs_resolve "$CRS_FLAG"
CRS="$CRS_EPSG"
TARGET_SRID="$CRS_SRID"

PGHOST="${PGHOST:-$ROOT/pgdata}"
PGPORT="${PGPORT:-5432}"
BUILD_DB="${BUILD_DB:-im_gpkg_build}"
GPKG_OUTPUT="${GPKG_OUTPUT:-$ROOT/gpkg/KartozaInfrastructureMapper.gpkg}"

VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
MAJOR="$(echo "$VERSION" | cut -d. -f1)"
MINOR="$(echo "$VERSION" | cut -d. -f2)"
PATCH="$(echo "$VERSION" | cut -d. -f3)"

for cmd in psql createdb dropdb ogr2ogr ogrinfo sha256sum sqlite3; do
    if ! command -v "$cmd" >/dev/null; then
        echo "ERROR: '$cmd' is not on PATH. Run inside 'nix develop'." >&2
        exit 1
    fi
done

# Bring up the project-local cluster if it isn't already serving.
bash "$ROOT/scripts/ensure_pg.sh"

BASELINE_FILES=(
    sql/0-meta.sql
    sql/1-infrastructure.sql
    sql/2-electricity.sql
    sql/3-water.sql
    sql/4-vegetation.sql
    sql/5-monitoring.sql
    sql/6-buildings.sql
    sql/7-fencing.sql
    sql/8-poi.sql
    sql/9-landuse.sql
    sql/10-gates.sql
    sql/11-poles.sql
    sql/12-culinary.sql
    sql/13-roads.sql
)

echo ">> Dropping and recreating throwaway database '$BUILD_DB'..."
dropdb -h "$PGHOST" -p "$PGPORT" --if-exists "$BUILD_DB"
createdb -h "$PGHOST" -p "$PGPORT" "$BUILD_DB"

PSQL=(psql -h "$PGHOST" -p "$PGPORT" -d "$BUILD_DB" -v ON_ERROR_STOP=1 -q)

echo ">> Enabling PostGIS..."
"${PSQL[@]}" -f sql/extensions.sql

echo ">> Applying baseline schema..."
for f in "${BASELINE_FILES[@]}"; do
    echo "   $f"
    "${PSQL[@]}" -f "$f"
done

echo ">> Applying fixtures..."
"${PSQL[@]}" -f sql/fixtures.sql

shopt -s nullglob
PG_MIGS=(sql/migrations/pg/v*.sql)
if [ ${#PG_MIGS[@]} -gt 0 ]; then
    mapfile -t PG_MIGS_SORTED < <(printf '%s\n' "${PG_MIGS[@]}" | sort -V)
    echo ">> Applying frozen PG migrations..."
    for mig in "${PG_MIGS_SORTED[@]}"; do
        echo "   $mig"
        "${PSQL[@]}" -f "$mig"
    done
fi

# Also apply work-in-progress UNRELEASED.sql so a broken or incomplete migration
# shows up here, in the fastest local dev loop, rather than only at release time.
# Safe: build_gpkg.sh is never part of the CI/release artifact pipeline (that's
# scripts/build_artifacts.sh, which only ever applies frozen vX.Y.Z migrations).
echo ">> Applying UNRELEASED PG migration (work in progress)..."
"${PSQL[@]}" -f sql/migrations/pg/UNRELEASED.sql

if [ -n "$TARGET_SRID" ]; then
    echo ">> Reprojecting all spatial columns to $CRS..."
    "${PSQL[@]}" <<SQL
DO \$\$
DECLARE
    rec RECORD;
    geom_type TEXT;
BEGIN
    FOR rec IN
        SELECT f_table_schema AS sch, f_table_name AS tbl, f_geometry_column AS col, type AS gtype
        FROM geometry_columns
        WHERE f_table_schema = 'public'
    LOOP
        EXECUTE format(
            'ALTER TABLE %I.%I ALTER COLUMN %I TYPE GEOMETRY(%s, $TARGET_SRID) USING ST_Transform(%I, $TARGET_SRID)',
            rec.sch, rec.tbl, rec.col, rec.gtype, rec.col
        );
        RAISE NOTICE 'Reprojected %.%.% (%) -> EPSG:$TARGET_SRID', rec.sch, rec.tbl, rec.col, rec.gtype;
    END LOOP;
END
\$\$;
SQL
fi

echo ">> Stamping baseline version v$VERSION..."
BASELINE_CHECKSUM=$(cat "${BASELINE_FILES[@]}" sql/fixtures.sql | sha256sum | awk '{print $1}')
"${PSQL[@]}" -c "
INSERT INTO schema_migrations
    (version, major, minor, patch, applied_by, checksum, is_baseline, notes)
VALUES
    ('v$VERSION', $MAJOR, $MINOR, $PATCH, 'build_gpkg.sh', '$BASELINE_CHECKSUM', TRUE, 'Initial baseline')
ON CONFLICT (version) DO NOTHING;
"

echo ">> Exporting to GeoPackage at $GPKG_OUTPUT..."
mkdir -p "$(dirname "$GPKG_OUTPUT")"
rm -f "$GPKG_OUTPUT"
ogr2ogr \
    -f GPKG \
    "$GPKG_OUTPUT" \
    PG:"host=$PGHOST port=$PGPORT dbname=$BUILD_DB" \
    -progress \
    -oo LIST_ALL_TABLES=YES

echo ">> Post-processing GeoPackage (recreating views)..."
# ogr2ogr materialises PG views as tables; drop and recreate as a real view.
sqlite3 "$GPKG_OUTPUT" <<'SQL'
DROP TABLE IF EXISTS current_schema_version;
DROP VIEW IF EXISTS current_schema_version;
CREATE VIEW current_schema_version AS
SELECT version, major, minor, patch, applied_at, is_baseline
FROM schema_migrations
ORDER BY major DESC, minor DESC, patch DESC
LIMIT 1;
DELETE FROM gpkg_contents WHERE table_name = 'current_schema_version';
SQL

echo ">> Registering GeoPackage Related Tables Extension relations..."
sqlite3 "$GPKG_OUTPUT" < "$ROOT/sql/gpkg_relations.sql"

echo ">> Dropping throwaway database..."
dropdb -h "$PGHOST" -p "$PGPORT" --if-exists "$BUILD_DB"

echo ""
echo ">> Build complete: $GPKG_OUTPUT"
echo ">> Layers:"
ogrinfo -ro -so "$GPKG_OUTPUT" 2>/dev/null | head -40
echo ""
echo ">> Schema version stamped on GPKG: $(sqlite3 "$GPKG_OUTPUT" 'SELECT version FROM current_schema_version;')"
