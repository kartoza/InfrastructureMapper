#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Build the mkdocs-material site in strict mode (mirrors CI).
set -euo pipefail
exec mkdocs build --strict "$@"
