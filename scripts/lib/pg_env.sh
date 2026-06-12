# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Shared environment + helpers for the scripts/*_pg.sh family.
# Intended to be sourced, not executed.

# Resolve repo root (works whether sourced via `nix run` wrapper or directly).
PG_REPO_ROOT="${PG_REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

export PGDATA="${PGDATA:-$PG_REPO_ROOT/pgdata}"
export PGHOST="${PGHOST:-$PGDATA}"
export PGPORT="${PGPORT:-5432}"
export PGDATABASE="${PGDATABASE:-gis}"

PG_LOG="$PGDATA/postgres.log"
PG_POSTGIS_FLAG="$PGDATA/.postgis_setup_done"

# Colour helpers (degrade gracefully if stdout isn't a tty).
if [ -t 1 ]; then
    PG_C_RESET=$'\033[0m'
    PG_C_DIM=$'\033[2m'
    PG_C_BOLD=$'\033[1m'
    PG_C_GREEN=$'\033[32m'
    PG_C_YELLOW=$'\033[33m'
    PG_C_RED=$'\033[31m'
    PG_C_CYAN=$'\033[36m'
else
    PG_C_RESET="" PG_C_DIM="" PG_C_BOLD="" PG_C_GREEN="" PG_C_YELLOW="" PG_C_RED="" PG_C_CYAN=""
fi

pg_msg_info() { printf '%s•%s %s\n' "$PG_C_CYAN" "$PG_C_RESET" "$*"; }
pg_msg_ok()   { printf '%s✓%s %s\n' "$PG_C_GREEN" "$PG_C_RESET" "$*"; }
pg_msg_warn() { printf '%s!%s %s\n' "$PG_C_YELLOW" "$PG_C_RESET" "$*"; }
pg_msg_err()  { printf '%s✗%s %s\n' "$PG_C_RED" "$PG_C_RESET" "$*" >&2; }

pg_is_initialized() { [ -f "$PGDATA/PG_VERSION" ]; }

pg_is_running() {
    pg_is_initialized || return 1
    pg_ctl -D "$PGDATA" status >/dev/null 2>&1
}

# One-word state, suitable for prompts: running | stopped | uninitialized.
pg_state() {
    if ! pg_is_initialized; then
        echo uninitialized
    elif pg_is_running; then
        echo running
    else
        echo stopped
    fi
}
