#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Generate qgis_projects/InfrastructureMapper.qgz by loading
# scripts/generate_project.py inside a real, headless QGIS process via its
# PYQGIS_STARTUP mechanism - so qgis.core and its Qt binding come from
# QGIS's own already-correct initialisation (whichever Qt version that QGIS
# build actually uses), rather than this project guessing a Qt binding and
# importing it directly.
#
# Requires: the target .gpkg already built (nix run .#build-gpkg) and
# Postgres reachable.
#
# Usage:
#   scripts/generate_project.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v qgis >/dev/null; then
    echo "ERROR: 'qgis' is not on PATH. Run inside 'nix develop'." >&2
    exit 1
fi

export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}"
# Headless/no-GPU environments have no GLX context for QGIS's canvas to
# probe at startup ("Fatal: Could not initialize GLX"); force Mesa's
# software rasteriser instead of a real GPU.
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
export PYQGIS_STARTUP="$ROOT/scripts/generate_project.py"

echo ">> Launching headless QGIS to run scripts/generate_project.py..."
# -platform (Qt's own CLI flag, authoritative over the env var) avoids QGIS
# still probing a real GLX/xcb context in environments with no X server at
# all, which the QT_QPA_PLATFORM env var alone did not prevent.
exec qgis --nologo --platform offscreen
