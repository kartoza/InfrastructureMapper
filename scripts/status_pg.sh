#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Report the state of the project-local Postgres cluster.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

state="$(pg_state)"

case "$state" in
    running)
        printf '%s● RUNNING%s  %s%s:%s%s\n' \
            "$PG_C_GREEN" "$PG_C_RESET" "$PG_C_BOLD" "$PGHOST" "$PGPORT" "$PG_C_RESET"
        ;;
    stopped)
        printf '%s● STOPPED%s  %s%s%s\n' \
            "$PG_C_YELLOW" "$PG_C_RESET" "$PG_C_DIM" "$PGDATA" "$PG_C_RESET"
        ;;
    uninitialized)
        printf '%s● NOT INITIALIZED%s  %srun: nix run .#pg-start%s\n' \
            "$PG_C_RED" "$PG_C_RESET" "$PG_C_DIM" "$PG_C_RESET"
        exit 0
        ;;
esac

if [ "$state" = "running" ]; then
    pg_version="$(postgres --version 2>/dev/null | awk '{print $NF}')"
    printf '%sPostgres%s  %s\n' "$PG_C_DIM" "$PG_C_RESET" "$pg_version"
    printf '%sData dir%s  %s\n' "$PG_C_DIM" "$PG_C_RESET" "$PGDATA"
    printf '%sLog file%s  %s\n' "$PG_C_DIM" "$PG_C_RESET" "$PG_LOG"
    echo
    printf '%sDatabases:%s\n' "$PG_C_BOLD" "$PG_C_RESET"
    psql -h "$PGHOST" -p "$PGPORT" -d postgres -tAc \
        "SELECT datname FROM pg_database WHERE NOT datistemplate ORDER BY datname;" \
        2>/dev/null | sed 's/^/  /'
fi
