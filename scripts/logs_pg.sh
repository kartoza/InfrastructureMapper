#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Follow the Postgres server log written by start_pg.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

if [ ! -f "$PG_LOG" ]; then
    pg_msg_warn "No log file at $PG_LOG yet — has the cluster ever been started?"
    exit 0
fi

pg_msg_info "Tailing $PG_LOG (Ctrl-C to stop)"
exec tail -F "$PG_LOG"
