#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Stop the project-local Postgres cluster under ./pgdata.
# Idempotent: safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

if ! pg_is_initialized; then
    pg_msg_warn "No cluster at $PGDATA — nothing to stop"
    exit 0
fi

if ! pg_is_running; then
    pg_msg_warn "PostgreSQL is not running"
    exit 0
fi

pg_msg_info "Stopping PostgreSQL ($PGHOST:$PGPORT)"
pg_ctl -D "$PGDATA" -o "-k $PGDATA -p $PGPORT" stop -m fast >/dev/null
pg_msg_ok "Stopped"
