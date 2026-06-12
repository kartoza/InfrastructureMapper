#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Restart the project-local Postgres cluster.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

if pg_is_initialized && pg_is_running; then
    bash "$SCRIPT_DIR/stop_pg.sh"
fi
bash "$SCRIPT_DIR/start_pg.sh"
