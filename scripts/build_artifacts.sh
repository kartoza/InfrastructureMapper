#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Orchestrator for build_artifacts.py: provisions a clean Postgres database,
# loads the baseline schema + fixtures + frozen migrations, calls the Python
# builder to emit composite + per-domain artifacts, then drops the build DB.
#
# Used by CI (Artifacts.yml + Release.yml) and locally via `nix run .#build-artifacts`.
#
# Usage:
#   scripts/build_artifacts.sh --version v0.2.0
#   scripts/build_artifacts.sh --version pr-123 --out /tmp/dist --skip-gpkg
#
# Honours PGHOST/PGPORT/PGUSER/PGPASSWORD from the environment so the same
# script works against the project-local pgdata cluster or a CI service
# container.

set -euo pipefail

VERSION=""
OUT_DIR=""
SKIP_GPKG=""
KEEP_DB=""

while [ $# -gt 0 ]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --out) OUT_DIR="$2"; shift 2 ;;
        --skip-gpkg) SKIP_GPKG="--skip-gpkg"; shift ;;
        --keep-db) KEEP_DB=1; shift ;;
        -h|--help)
            sed -n '2,20p' "$0"
            exit 0 ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 2 ;;
    esac
done

if [ -z "$VERSION" ]; then
    echo "Error: --version is required (e.g. v0.2.0 or pr-123-abc1234)" >&2
    exit 2
fi

REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO"
OUT_DIR="${OUT_DIR:-$REPO/dist}"
mkdir -p "$OUT_DIR"

# When running against the project-local cluster, bring it up if it's down.
if [ -x scripts/ensure_pg.sh ]; then
    bash scripts/ensure_pg.sh >/dev/null 2>&1 || true
fi

: "${PGHOST:=localhost}"
: "${PGPORT:=5432}"
: "${PGUSER:=$USER}"
: "${PGDATABASE:=gis}"
export PGHOST PGPORT PGUSER PGDATABASE
if [ -n "${PGPASSWORD:-}" ]; then export PGPASSWORD; fi

# Build DB name: lowercase, alnum only, capped, salted with PID to avoid clashes.
SAFE_VER="$(echo "$VERSION" | tr -c '[:alnum:]' '_' | cut -c1-30)"
BUILD_DB="im_artifacts_${SAFE_VER}_$$"

PSQL="psql -h $PGHOST -p $PGPORT -U $PGUSER -v ON_ERROR_STOP=1 -q"

echo "==> Creating build database: $BUILD_DB"
createdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$BUILD_DB"

cleanup() {
    if [ -z "$KEEP_DB" ]; then
        echo "==> Dropping build database: $BUILD_DB"
        dropdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" --if-exists "$BUILD_DB" || true
    else
        echo "==> Leaving build database in place: $BUILD_DB"
    fi
}
trap cleanup EXIT

echo "==> Loading extensions + meta"
$PSQL -d "$BUILD_DB" -f sql/extensions.sql
$PSQL -d "$BUILD_DB" -f sql/0-meta.sql

echo "==> Loading per-domain schemas (1..13)"
for n in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
    for f in sql/${n}-*.sql; do
        [ -f "$f" ] || continue
        $PSQL -d "$BUILD_DB" -f "$f"
    done
done

echo "==> Loading fixtures"
$PSQL -d "$BUILD_DB" -f sql/fixtures.sql

# Stamp the baseline migration so schema_migrations reflects the version.
MAJ="${VERSION#v}"; MAJ="${MAJ%%.*}"
REST="${VERSION#v}"
MIN="$(echo "$REST" | cut -d. -f2)"
PAT="$(echo "$REST" | cut -d. -f3)"
# For non-vN.N.N versions (e.g. pr-123) fall back to 0.0.0 so the row inserts.
case "$MAJ$MIN$PAT" in
    *[!0-9]*|"") MAJ=0; MIN=0; PAT=0 ;;
esac
echo "==> Stamping baseline $VERSION ($MAJ.$MIN.$PAT)"
$PSQL -d "$BUILD_DB" -c "INSERT INTO schema_migrations \
    (version, major, minor, patch, applied_by, checksum, is_baseline, notes) \
    VALUES ('$VERSION', $MAJ, $MIN, $PAT, 'build-artifacts', 'baseline', \
    TRUE, 'Baseline stamped by scripts/build_artifacts.sh') \
    ON CONFLICT (version) DO NOTHING;"

# Apply any frozen forward migrations on top.
shopt -s nullglob
for mig in sql/migrations/pg/v*.sql; do
    echo "==> Applying $mig"
    $PSQL -d "$BUILD_DB" -f "$mig"
done
shopt -u nullglob

echo "==> Running build_artifacts.py against $BUILD_DB"
python3 scripts/build_artifacts.py \
    --version "$VERSION" \
    --out "$OUT_DIR" \
    --pg-host "$PGHOST" \
    --pg-port "$PGPORT" \
    --pg-user "$PGUSER" \
    --pg-database "$BUILD_DB" \
    --pg-password "${PGPASSWORD:-}" \
    $SKIP_GPKG

echo
echo "Done. Artifacts in: $OUT_DIR"
