#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Bring up the project-local Postgres/PostGIS cluster under ./pgdata.
# Idempotent: safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

mkdir -p "$PGDATA"
chmod 700 "$PGDATA"

if ! pg_is_initialized; then
    pg_msg_info "Initialising PostgreSQL cluster in $PGDATA"
    initdb -D "$PGDATA" --locale=C --encoding=UTF8 >/dev/null
fi

if pg_is_running; then
    pg_msg_ok "PostgreSQL already running on $PGHOST:$PGPORT"
else
    pg_msg_info "Starting PostgreSQL on $PGHOST:$PGPORT"
    pg_ctl -D "$PGDATA" \
        -l "$PG_LOG" \
        -o "-k $PGDATA -p $PGPORT" \
        -w start >/dev/null
    pg_msg_ok "PostgreSQL started (logs: $PG_LOG)"
fi

SOCKET="$PGDATA/.s.PGSQL.$PGPORT"
if [ ! -S "$SOCKET" ]; then
    pg_msg_err "PostgreSQL socket file not found at $SOCKET"
    exit 1
fi

if [ ! -f "$PG_POSTGIS_FLAG" ]; then
    pg_msg_info "Creating database '$PGDATABASE' and PostGIS extension"
    createdb "$PGDATABASE"
    psql -d "$PGDATABASE" -c "CREATE EXTENSION IF NOT EXISTS postgis;" >/dev/null
    touch "$PG_POSTGIS_FLAG"
    pg_msg_ok "PostGIS ready in '$PGDATABASE'"
fi

printf '\n%sConnect:%s psql -h %s -p %s -d %s\n' \
    "$PG_C_DIM" "$PG_C_RESET" "$PGHOST" "$PGPORT" "$PGDATABASE"
