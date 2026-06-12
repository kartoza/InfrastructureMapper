#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# DESTRUCTIVE: stop the local cluster, delete ./pgdata, then re-init.
# Use this when the cluster is in a wedged state and you want a clean slate.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

confirm() {
    local prompt="This will DELETE $PGDATA and re-initialise. Continue?"
    if command -v gum >/dev/null 2>&1; then
        gum confirm --default=No "$prompt"
        return $?
    fi
    printf '%s [y/N] ' "$prompt"
    read -r reply
    case "$reply" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

if ! confirm; then
    pg_msg_warn "Aborted — nothing changed"
    exit 1
fi

if pg_is_initialized && pg_is_running; then
    bash "$SCRIPT_DIR/stop_pg.sh"
fi

if [ -d "$PGDATA" ]; then
    pg_msg_info "Removing $PGDATA"
    rm -rf "$PGDATA"
fi

exec bash "$SCRIPT_DIR/start_pg.sh"
