#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Schema-immutability gate. Enforces:
#
#   1. Top-level sql/*.sql files (the baseline) are immutable once committed.
#      New top-level files for new capture domains are allowed — those become
#      immutable from their first commit.
#
#   2. sql/migrations/{pg,gpkg}/v*.sql (released migrations) are immutable once
#      committed.
#
#   3. sql/migrations/{pg,gpkg}/UNRELEASED.sql is editable. Every SQL statement
#      appended to it must be preceded by an "-- Issue #NNN: description" line.
#
# Runs as a pre-commit hook and as the same logic in CI.
#
# Mode:
#   default        — check staged files (pre-commit)
#   --all          — check the entire tree against HEAD (CI / manual)
#   --base <ref>   — check the diff between <ref> and HEAD (CI on PRs)

set -euo pipefail

MODE="staged"
BASE_REF=""

while [ $# -gt 0 ]; do
    case "$1" in
        --all) MODE="all"; shift ;;
        --base) MODE="base"; BASE_REF="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,30p' "$0"
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

# The semantic we enforce is "this branch must not modify files that already
# exist on the integration branch (main)". A feature branch can freely
# introduce new top-level sql/N-*.sql files (new capture domains) and freely
# edit its own UNRELEASED.sql; what it cannot do is touch a baseline file
# that's already on main.
#
# Pick the integration ref: prefer origin/main, then main, then origin/master,
# then master. Fall back to HEAD if none reachable (preserves the old single-
# repo behaviour).
default_integration_ref() {
    for ref in origin/main main origin/master master; do
        if git rev-parse --verify --quiet "$ref" > /dev/null; then
            echo "$ref"
            return 0
        fi
    done
    echo "HEAD"
}

# Resolve the set of files this run should look at, and the "base" ref against
# which a frozen-file modification is judged.
case "$MODE" in
    staged)
        BASE_REF="$(default_integration_ref)"
        # Files this commit + this branch are changing relative to the base.
        STAGED_FILES=$(git diff --cached --name-only --diff-filter=AMR)
        BRANCH_FILES=$(git diff --name-only --diff-filter=AMR "$BASE_REF"..HEAD)
        FILES=$(printf '%s\n%s\n' "$STAGED_FILES" "$BRANCH_FILES" | sort -u | grep -v '^$' || true)
        ;;
    all)
        BASE_REF="$(default_integration_ref)"
        FILES=$(git diff --name-only --diff-filter=AMR "$BASE_REF"..HEAD)
        # Also include any working-tree changes not yet committed.
        WT_FILES=$(git diff --name-only --diff-filter=AMR)
        FILES=$(printf '%s\n%s\n' "$FILES" "$WT_FILES" | sort -u | grep -v '^$' || true)
        ;;
    base)
        FILES=$(git diff --name-only --diff-filter=AMR "$BASE_REF"..HEAD)
        ;;
esac
PREV_REF="$BASE_REF"

REJECTED=()
ANNOTATION_ERRORS=()

is_frozen_path() {
    case "$1" in
        sql/[0-9]*.sql)                          return 0 ;;
        sql/extensions.sql|sql/fixtures.sql)     return 0 ;;
        sql/migrations/pg/v*.sql)                return 0 ;;
        sql/migrations/gpkg/v*.sql)              return 0 ;;
        *)                                       return 1 ;;
    esac
}

is_unreleased_path() {
    case "$1" in
        sql/migrations/pg/UNRELEASED.sql|sql/migrations/gpkg/UNRELEASED.sql) return 0 ;;
        *) return 1 ;;
    esac
}

# Pull the staged content of a file (for pre-commit) or HEAD (for --all).
file_content() {
    local f="$1"
    case "$MODE" in
        staged) git show ":$f" 2>/dev/null || true ;;
        all|base) [ -f "$f" ] && cat "$f" || true ;;
    esac
}

check_unreleased_annotations() {
    local f="$1"
    file_content "$f" | awk -v file="$f" '
    BEGIN { last_issue = -1; line_no = 0 }
    {
        line_no++
        # Track the most recent Issue header line (anywhere above).
        if ($0 ~ /^[[:space:]]*--[[:space:]]*Issue[[:space:]]*#[0-9]+[[:space:]]*:/) {
            last_issue = line_no
            next
        }
        # Detect SQL statements that need to be covered by a preceding Issue line.
        # We trigger on lines starting (after optional whitespace) with a top-level
        # DDL/DML keyword. Comments and blank lines are ignored.
        if ($0 ~ /^[[:space:]]*--/)         next
        if ($0 ~ /^[[:space:]]*$/)          next
        upper = toupper($0)
        if (upper ~ /^[[:space:]]*(CREATE|ALTER|DROP|INSERT|UPDATE|DELETE|TRUNCATE|GRANT|REVOKE|COMMENT|WITH|SELECT|REINDEX|ANALYZE|VACUUM|REFRESH|SET)[[:space:]]/) {
            if (last_issue < 0) {
                print file ":" line_no ": SQL statement without preceding `-- Issue #NNN:` annotation"
                exit_code = 1
            }
        }
    }
    END { exit exit_code+0 }
    '
}

# Bootstrap exemption: if the immutability hook itself doesn't exist on the
# base ref, this branch is introducing it. Skip the frozen-file rejection so
# the establishing PR can land cleanly. The Issue-NNN annotation check still
# runs (it's about migration hygiene, not baseline immutability).
#
# Caveat: a stale local origin/main can trigger bootstrap mode even when
# main upstream has the hook. To prevent that hiding a real violation, try
# to fetch a fresh origin/main first in staged/all modes; if that fails
# (offline), emit a loud warning instead of silently skipping.
BOOTSTRAP=0
if [ "$MODE" != "base" ] && git remote get-url origin >/dev/null 2>&1; then
    git fetch --quiet origin main 2>/dev/null || true
fi
if ! git cat-file -e "$PREV_REF:scripts/check_schema_immutability.sh" 2>/dev/null; then
    BOOTSTRAP=1
    echo "⚠️  Bootstrap mode: '$PREV_REF' does not yet contain scripts/check_schema_immutability.sh." >&2
    echo "    Baseline-modification check is SKIPPED locally — CI will still" >&2
    echo "    enforce it against the real merge base. If you have not run" >&2
    echo "    'git fetch origin main' recently, do that first to avoid a" >&2
    echo "    surprise rejection on push." >&2
    echo "" >&2
fi

for f in $FILES; do
    case "$f" in
        sql/*) ;;
        *) continue ;;
    esac

    if [ "$BOOTSTRAP" = 0 ] && is_frozen_path "$f"; then
        # Reject only if the file existed in the base ref AND content differs.
        if git cat-file -e "$PREV_REF:$f" 2>/dev/null; then
            if ! git diff --quiet "$PREV_REF" -- "$f" 2>/dev/null; then
                REJECTED+=("$f")
            elif [ "$MODE" = "staged" ] && ! git diff --cached --quiet -- "$f" 2>/dev/null; then
                REJECTED+=("$f")
            fi
        fi
    fi

    if is_unreleased_path "$f"; then
        if ! check_unreleased_annotations "$f"; then
            ANNOTATION_ERRORS+=("$f")
        fi
    fi
done

EXIT=0

if [ ${#REJECTED[@]} -gt 0 ]; then
    EXIT=1
    echo "🚫 The following frozen schema files cannot be modified:" >&2
    printf '   %s\n' "${REJECTED[@]}" >&2
    echo "" >&2
    echo "   Baseline (sql/N-*.sql, extensions.sql, fixtures.sql) and released" >&2
    echo "   migrations (sql/migrations/{pg,gpkg}/vX.Y.Z.sql) are immutable." >&2
    echo "   Append your changes to sql/migrations/pg/UNRELEASED.sql and" >&2
    echo "   sql/migrations/gpkg/UNRELEASED.sql instead." >&2
    echo "" >&2
fi

if [ ${#ANNOTATION_ERRORS[@]} -gt 0 ]; then
    EXIT=1
    echo "🚫 Issue-annotation violations:" >&2
    for f in "${ANNOTATION_ERRORS[@]}"; do
        check_unreleased_annotations "$f" >&2 || true
    done
    echo "" >&2
    echo "   Every SQL statement in UNRELEASED.sql must be preceded by:" >&2
    echo "     -- Issue #NNN: short description" >&2
fi

exit $EXIT
