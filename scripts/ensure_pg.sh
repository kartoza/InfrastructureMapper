#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Make sure a usable Postgres is reachable at $PGHOST:$PGPORT.
#
# Decision tree:
#   1. If `psql -c 'SELECT 1'` already works against $PGHOST:$PGPORT, return.
#   2. If $PGHOST points inside the repo (the project-local cluster),
#      bring it up via scripts/start_pg.sh.
#   3. Otherwise we're talking to an external service (CI, dev DB) that
#      this script can't manage — exit with a clear error.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

if psql -h "$PGHOST" -p "$PGPORT" -d postgres -tAc 'SELECT 1' >/dev/null 2>&1; then
    exit 0
fi

case "$PGHOST" in
    "$PG_REPO_ROOT"|"$PG_REPO_ROOT"/*)
        pg_msg_info "PostgreSQL not reachable at $PGHOST:$PGPORT — starting local cluster"
        exec bash "$SCRIPT_DIR/start_pg.sh"
        ;;
    *)
        pg_msg_err "PostgreSQL not reachable at $PGHOST:$PGPORT"
        pg_msg_err "PGHOST is outside the repo, so this script will not auto-start it."
        pg_msg_err "Start your external Postgres, or unset PGHOST to use the project cluster."
        exit 1
        ;;
esac
