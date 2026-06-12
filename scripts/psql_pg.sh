#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Drop into psql against the project-local cluster.
# Extra arguments are forwarded to psql verbatim
# (e.g. `nix run .#pg-psql -- -c 'SELECT version();'`).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

if ! pg_is_running; then
    pg_msg_err "PostgreSQL is not running. Start it with: nix run .#pg-start"
    exit 1
fi

exec psql -h "$PGHOST" -p "$PGPORT" -d "$PGDATABASE" "$@"
