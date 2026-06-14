#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Cut a new release of the schema in two steps so the flow plays nicely
# with branch protection rules that require PRs and status checks on
# main:
#
#   1. scripts/release.sh --bump patch|minor|major --commit
#        Prepares the release commit (rotates UNRELEASED.sql files,
#        bumps VERSION, regenerates schema docs) on a new branch
#        `release/vX.Y.Z`, pushes the branch, opens a PR.
#
#   2. After the PR has merged into main, run:
#        scripts/release.sh --tag
#        Tags main HEAD as vX.Y.Z (read from the committed VERSION
#        file) and pushes the tag. Release.yml fires on the tag and
#        publishes the release artifacts.
#
# Use `--empty` with `--commit` to allow a release when both
# UNRELEASED.sql files contain no `-- Issue #NNN:` blocks (e.g. for a
# docs-only patch bump).
#
# Usage:
#   scripts/release.sh --bump patch|minor|major --commit [--empty]
#   scripts/release.sh --tag

set -euo pipefail

BUMP=""
MODE=""
ALLOW_EMPTY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --bump) BUMP="$2"; shift 2 ;;
        --bump=*) BUMP="${1#--bump=}"; shift ;;
        --commit) MODE="commit"; shift ;;
        --tag) MODE="tag"; shift ;;
        --empty) ALLOW_EMPTY=1; shift ;;
        -h|--help) sed -n '2,28p' "$0"; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$MODE" ]; then
    echo "ERROR: pick a mode: --commit (open release PR) or --tag (tag merged release)." >&2
    exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# -----------------------------------------------------------------
# Mode 2: --tag  — assumes the release PR has merged into main.
# -----------------------------------------------------------------
if [ "$MODE" = "tag" ]; then
    if [ -n "$BUMP" ]; then
        echo "ERROR: --bump is meaningless with --tag (version comes from VERSION)." >&2
        exit 2
    fi
    CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    if [ "$CUR_BRANCH" != "main" ]; then
        echo "ERROR: --tag must run on main (currently on $CUR_BRANCH)." >&2
        exit 2
    fi
    echo ">> Fetching latest main..."
    git fetch origin main
    LOCAL="$(git rev-parse HEAD)"
    REMOTE="$(git rev-parse origin/main)"
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "ERROR: local main ($LOCAL) is not at origin/main ($REMOTE)." >&2
        echo "       git pull --ff-only first." >&2
        exit 1
    fi
    VERSION="$(tr -d '[:space:]' < VERSION)"
    VTAG="v$VERSION"
    if git rev-parse "$VTAG" >/dev/null 2>&1; then
        echo "ERROR: tag $VTAG already exists." >&2
        echo "       To re-cut the release: git tag -d $VTAG && git push --delete origin $VTAG" >&2
        exit 1
    fi
    echo ">> Tagging $VTAG at $(git rev-parse --short HEAD): $(git log -1 --pretty=%s)"
    git tag -a "$VTAG" -m "Release $VTAG"
    echo ">> Pushing tag..."
    git push origin "$VTAG"
    echo ">> Done. Release.yml will build artifacts and publish the GitHub release."
    exit 0
fi

# -----------------------------------------------------------------
# Mode 1: --commit  — prepare release branch + PR.
# -----------------------------------------------------------------
case "$BUMP" in
    major|minor|patch) ;;
    *) echo "ERROR: --commit requires --bump major|minor|patch." >&2; exit 2 ;;
esac

# Insist on starting from a clean main so the release branch is reproducible.
CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CUR_BRANCH" != "main" ]; then
    echo "ERROR: --commit must start from main (currently on $CUR_BRANCH)." >&2
    exit 2
fi
if [ -n "$(git status --porcelain | grep -vE '^\?\?')" ]; then
    echo "ERROR: working tree has staged or modified files; commit or stash first." >&2
    exit 2
fi
echo ">> Fetching latest main..."
git fetch origin main
LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse origin/main)"
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "ERROR: local main is not at origin/main; git pull --ff-only first." >&2
    exit 1
fi

CUR="$(tr -d '[:space:]' < VERSION)"
IFS='.' read -r M N P <<< "$CUR"

case "$BUMP" in
    major) M=$((M + 1)); N=0; P=0 ;;
    minor) N=$((N + 1)); P=0 ;;
    patch) P=$((P + 1)) ;;
esac

NEW="$M.$N.$P"
VNEW="v$NEW"
BRANCH="release/$VNEW"

echo ">> Current version: $CUR  →  New version: $NEW"
echo ">> Release branch: $BRANCH"

if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    echo "ERROR: branch $BRANCH already exists locally; delete it first." >&2
    exit 1
fi
if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    echo "ERROR: branch $BRANCH already exists on origin; delete it first." >&2
    exit 1
fi

PG_UNREL=sql/migrations/pg/UNRELEASED.sql
GPKG_UNREL=sql/migrations/gpkg/UNRELEASED.sql

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

# Cut the release branch from current main HEAD.
git checkout -b "$BRANCH"

# Rename UNRELEASED -> vX.Y.Z and create new empty UNRELEASED stubs.
HEADER_TEMPLATE_PG=$(head -20 "$PG_UNREL" | grep -E '^--' | head -20)
HEADER_TEMPLATE_GPKG=$(head -25 "$GPKG_UNREL" | grep -E '^--' | head -25)

git mv "$PG_UNREL" "sql/migrations/pg/$VNEW.sql"
git mv "$GPKG_UNREL" "sql/migrations/gpkg/$VNEW.sql"

{
    printf '%s\n' "$HEADER_TEMPLATE_PG"
} > "$PG_UNREL"
{
    printf '%s\n' "$HEADER_TEMPLATE_GPKG"
} > "$GPKG_UNREL"

echo "$NEW" > VERSION

echo ">> Renamed UNRELEASED.sql → $VNEW.sql"
echo ">> Wrote VERSION=$NEW"

# Regenerate schema reference docs (best-effort; needs Postgres running).
if command -v psql >/dev/null && pg_isready -h "${PGHOST:-$ROOT/pgdata}" -p "${PGPORT:-5432}" -q 2>/dev/null; then
    echo ">> Regenerating schema reference docs..."
    .venv/bin/python scripts/generate_schema_docs.py || {
        echo "WARNING: doc regeneration failed; continue anyway." >&2
    }
else
    echo ">> Skipping doc regeneration (Postgres not reachable)."
fi

# Stage everything that legitimately belongs in the release commit. The
# regenerated docs live under docs/data-model/ (not sql/ as in the
# pre-mkdocs layout); include them so the release commit + the
# subsequent pre-push schema-reference hook agree on what's on disk.
git add VERSION \
    "$PG_UNREL" "$GPKG_UNREL" \
    "sql/migrations/pg/$VNEW.sql" "sql/migrations/gpkg/$VNEW.sql" \
    docs/data-model/*.md

git commit -m "Release $VNEW"

echo ">> Pushing $BRANCH..."
git push -u origin "$BRANCH"

# Open the PR via gh CLI. Falls back to printing the compare URL if gh
# isn't available or authenticated.
PR_BODY=$(cat <<EOF
Release $VNEW.

- Rotates \`sql/migrations/{pg,gpkg}/UNRELEASED.sql\` to \`$VNEW.sql\`
  (frozen, immutable from here on).
- Bumps \`VERSION\` to \`$NEW\`.
- Refreshes per-domain schema reference docs.

Once this PR merges, run \`scripts/release.sh --tag\` on \`main\` to
tag $VNEW and trigger the Release workflow.
EOF
)

if command -v gh >/dev/null 2>&1; then
    echo ">> Opening pull request..."
    if gh pr create --base main --head "$BRANCH" \
        --title "Release $VNEW" --body "$PR_BODY" 2>&1; then
        :
    else
        echo "WARNING: gh pr create failed. Open it manually." >&2
    fi
else
    REPO_URL="$(git config --get remote.origin.url | sed -E 's|git@github.com:|https://github.com/|; s|\.git$||')"
    echo ">> Open PR manually: $REPO_URL/compare/main...$BRANCH"
fi

echo
echo ">> Release $VNEW prepared on branch $BRANCH."
echo ">> After the PR merges to main:"
echo ">>     git checkout main && git pull --ff-only"
echo ">>     scripts/release.sh --tag"
