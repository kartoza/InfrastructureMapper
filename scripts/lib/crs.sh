# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Shared CRS resolution helpers for the scripts/*.sh family.
# Intended to be sourced, not executed.
#
# Contract: the chosen CRS is remembered in a single-line file, ".im-crs"
# at the repo root (gitignored — it is machine-local state, not schema).
# Resolution order: explicit flag > remembered file > interactive prompt.

CRS_REPO_ROOT="${CRS_REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CRS_STATE_FILE="$CRS_REPO_ROOT/.im-crs"

# Normalises "EPSG:3857" or "3857" into "EPSG:<n>" + bare "<n>". Exits 2 on
# a malformed value. Sets the globals CRS_EPSG ("EPSG:<n>") and CRS_SRID
# ("<n>").
crs_validate() {
    local input="$1"
    case "$input" in
        EPSG:[0-9]*) CRS_SRID="${input#EPSG:}"; CRS_EPSG="$input" ;;
        [0-9]*)      CRS_SRID="$input"; CRS_EPSG="EPSG:$input" ;;
        *)
            echo "ERROR: CRS must be like 'EPSG:3857' or just '3857', got '$input'." >&2
            exit 2
            ;;
    esac
}

crs_warn_if_geographic() {
    if [ "$1" = "4326" ]; then
        echo "⚠️  WARNING: EPSG:4326 is a geographic CRS — distances and areas computed in" >&2
        echo "    it are only accurate to ~2 m. Pick a metric CRS (UTM zone, EPSG:3857)" >&2
        echo "    for field work needing precise measurements." >&2
        echo "" >&2
    fi
}

crs_remembered() {
    [ -f "$CRS_STATE_FILE" ] && tr -d '[:space:]' < "$CRS_STATE_FILE"
}

crs_remember() {
    printf '%s\n' "$1" > "$CRS_STATE_FILE"
}

# Resolves the CRS to use: explicit $1 (may be empty) > remembered file >
# interactive prompt. Validates and persists the result. Sets CRS_EPSG and
# CRS_SRID; also prints a one-line note to stderr saying where the value
# came from.
crs_resolve() {
    local flag="$1"
    local source=""
    local value=""

    if [ -n "$flag" ]; then
        value="$flag"
        source="--crs flag"
    else
        value="$(crs_remembered || true)"
        if [ -n "$value" ]; then
            source="remembered in $CRS_STATE_FILE"
        fi
    fi

    if [ -z "$value" ]; then
        if [ ! -t 0 ]; then
            echo "ERROR: no CRS given, none remembered, and stdin is not a terminal." >&2
            echo "       Pass --crs EPSG:NNNN, or run interactively once to set it." >&2
            exit 2
        fi
        read -r -p "Target CRS for this checkout (e.g. EPSG:4326, EPSG:32734): " value
        source="interactive prompt"
    fi

    crs_validate "$value"
    crs_warn_if_geographic "$CRS_SRID"
    crs_remember "$CRS_EPSG"
    echo ">> Using CRS $CRS_EPSG ($source); remembered in $CRS_STATE_FILE" >&2
}
