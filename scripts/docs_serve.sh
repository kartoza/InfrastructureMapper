#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Serve the mkdocs-material site locally with live reload.
set -euo pipefail
exec mkdocs serve "$@"
