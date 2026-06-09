#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Cut a new release of the schema.
#
# Steps:
#   1. Read current VERSION; compute the next version from --bump.
#   2. Verify UNRELEASED.sql files have something to release (or use --empty).
#   3. Rename sql/migrations/{pg,gpkg}/UNRELEASED.sql -> vX.Y.Z.sql.
#   4. Create fresh empty UNRELEASED.sql files.
#   5. Write the new version into VERSION.
#   6. Regenerate per-component schema reference docs.
#   7. Commit and tag (only with --commit).
#
# Usage:
#   scripts/release.sh --bump patch|minor|major [--commit] [--empty]
#
# The GitHub Action on tag push then builds and publishes release artifacts.

set -euo pipefail

BUMP=""
DO_COMMIT=0
ALLOW_EMPTY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --bump) BUMP="$2"; shift 2 ;;
        --bump=*) BUMP="${1#--bump=}"; shift ;;
        --commit) DO_COMMIT=1; shift ;;
        --empty) ALLOW_EMPTY=1; shift ;;
        -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

case "$BUMP" in
    major|minor|patch) ;;
    *) echo "ERROR: --bump must be major, minor, or patch." >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

CUR="$(tr -d '[:space:]' < VERSION)"
IFS='.' read -r M N P <<< "$CUR"

case "$BUMP" in
    major) M=$((M + 1)); N=0; P=0 ;;
    minor) N=$((N + 1)); P=0 ;;
    patch) P=$((P + 1)) ;;
esac

NEW="$M.$N.$P"
VNEW="v$NEW"

echo ">> Current version: $CUR  →  New version: $NEW"

PG_UNREL=sql/migrations/pg/UNRELEASED.sql
GPKG_UNREL=sql/migrations/gpkg/UNRELEASED.sql

# Determine "has content" by checking if there is at least one Issue-annotated block.
has_content() {
    grep -E '^[[:space:]]*--[[:space:]]*Issue[[:space:]]*#[0-9]+[[:space:]]*:' "$1" > /dev/null 2>&1
}

if ! has_content "$PG_UNREL" && ! has_content "$GPKG_UNREL"; then
    if [ "$ALLOW_EMPTY" = 0 ]; then
        echo "ERROR: both UNRELEASED.sql files are empty (no '-- Issue #NNN:' blocks)." >&2
        echo "       Pass --empty to release anyway (e.g. for a docs-only patch bump)." >&2
        exit 1
    fi
    echo ">> No migration content; releasing empty migration files."
fi

# Rename UNRELEASED -> vX.Y.Z and create new empty UNRELEASED stubs.
HEADER_TEMPLATE_PG=$(head -20 "$PG_UNREL" | grep -E '^--' | head -20)
HEADER_TEMPLATE_GPKG=$(head -25 "$GPKG_UNREL" | grep -E '^--' | head -25)

git mv "$PG_UNREL" "sql/migrations/pg/$VNEW.sql"
git mv "$GPKG_UNREL" "sql/migrations/gpkg/$VNEW.sql"

# Recreate empty UNRELEASED.sql with the previous header preserved.
{
    printf '%s\n' "$HEADER_TEMPLATE_PG"
} > "$PG_UNREL"
{
    printf '%s\n' "$HEADER_TEMPLATE_GPKG"
} > "$GPKG_UNREL"

echo "$NEW" > VERSION

echo ">> Renamed UNRELEASED.sql → $VNEW.sql"
echo ">> Wrote VERSION=$NEW"

# Refresh docs (best-effort; needs PG running).
if command -v psql >/dev/null && pg_isready -h "${PGHOST:-$ROOT/pgdata}" -p "${PGPORT:-5432}" -q 2>/dev/null; then
    echo ">> Regenerating schema reference docs..."
    .venv/bin/python scripts/generate_schema_docs.py || {
        echo "WARNING: doc regeneration failed; continue anyway." >&2
    }
else
    echo ">> Skipping doc regeneration (Postgres not reachable)."
fi

if [ "$DO_COMMIT" = 1 ]; then
    git add VERSION "$PG_UNREL" "$GPKG_UNREL" "sql/migrations/pg/$VNEW.sql" "sql/migrations/gpkg/$VNEW.sql" sql/*.md
    git commit -m "Release $VNEW"
    git tag -a "$VNEW" -m "Release $VNEW"
    echo ">> Committed and tagged $VNEW. Push with: git push && git push --tags"
else
    echo ">> Skipping commit (pass --commit to commit and tag in one step)."
fi
