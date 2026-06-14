#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#
# Branded welcome banner printed on `nix develop` entry.
# Renders with gum when available; degrades to plain echo otherwise.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/pg_env.sh
source "$SCRIPT_DIR/lib/pg_env.sh"

# Kartoza Brand Pack palette (hex; mapped to ANSI 24-bit by gum/terminal).
# Source: docs/stylesheets/kartoza-tokens.css.
KZ_BLUE="#54A2CC"        # primary accent (chrome, borders, headings)
KZ_AMBER="#EEB348"       # highlight accent (banner subtitle, eyebrows)
KZ_GREY="#8A8B8B"        # structural mid-grey
KZ_CHARCOAL="#383939"    # body text on light surfaces (used sparingly here)
KZ_CLOUD="#F5F5F2"       # near-white default text on dark terminals
# Status palette (FR-014 / Appendix A).
KZ_SUCCESS="#3C7D54"
KZ_WARN="#EEB348"
KZ_ERROR="#B0473C"

VERSION="$(tr -d '[:space:]' < "$PG_REPO_ROOT/VERSION" 2>/dev/null || echo unknown)"

pg_status_chip() {
    case "$(pg_state)" in
        running)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "$KZ_SUCCESS" --bold "● RUNNING"
            else
                printf '%s● RUNNING%s' "$PG_C_GREEN" "$PG_C_RESET"
            fi
            ;;
        stopped)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "$KZ_WARN" --bold "● STOPPED"
            else
                printf '%s● STOPPED%s' "$PG_C_YELLOW" "$PG_C_RESET"
            fi
            ;;
        uninitialized)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "$KZ_ERROR" --bold "● NOT INITIALIZED"
            else
                printf '%s● NOT INITIALIZED%s' "$PG_C_RED" "$PG_C_RESET"
            fi
            ;;
    esac
}

print_banner_gum() {
    # Flat panel: Blue border, Cloud title on the terminal's own background
    # (no fill), Amber accent line. No gradient (FR-033).
    gum style \
        --border rounded \
        --border-foreground "$KZ_BLUE" \
        --foreground "$KZ_CLOUD" \
        --padding "1 3" --margin "1 0" \
        --bold \
        "KARTOZA · INFRASTRUCTURE MAPPER  v$VERSION" \
        "$(gum style --foreground "$KZ_AMBER" "Open Source Geospatial Solutions")"
}

print_banner_plain() {
    printf '\n%sKARTOZA · INFRASTRUCTURE MAPPER  v%s%s\n' \
        "$PG_C_BOLD" "$VERSION" "$PG_C_RESET"
    printf '%sOpen Source Geospatial Solutions%s\n\n' \
        "$PG_C_DIM" "$PG_C_RESET"
}

section() {
    local icon="$1" title="$2"
    printf '\n%s%s  %s%s\n' "$PG_C_BOLD" "$icon" "$title" "$PG_C_RESET"
}

row() {
    local cmd="$1" desc="$2"
    printf '   %s%-32s%s %s\n' "$PG_C_CYAN" "$cmd" "$PG_C_RESET" "$desc"
}

if command -v gum >/dev/null 2>&1; then
    print_banner_gum
else
    print_banner_plain
fi

printf '%s🐘  Postgres%s   %s   %sdir: %s · port: %s%s\n' \
    "$PG_C_BOLD" "$PG_C_RESET" \
    "$(pg_status_chip)" \
    "$PG_C_DIM" "$PGHOST" "$PGPORT" "$PG_C_RESET"
row "nix run .#pg-start"     "Start (initdb on first run, idempotent)"
row "nix run .#pg-stop"      "Stop the cluster"
row "nix run .#pg-status"    "Show state, version, databases"
row "nix run .#pg-restart"   "Stop then start"
row "nix run .#pg-psql"      "Open psql against the 'gis' DB"
row "nix run .#pg-logs"      "Tail the server log"
row "nix run .#pg-reset"     "DESTROY pgdata and re-initialise (confirms first)"

section "📦" "Schema lifecycle"
row "nix run .#build-gpkg"      "Build gpkg/KartozaInfrastructureMapper.gpkg (--crs EPSG:NNNN)"
row "nix run .#build-artifacts" "Build composite + per-domain SQL/GPKG release artifacts"
row "nix run .#schema-diff"     "migra diff between two composite SQL bundles"
row "nix run .#migrate-pg"      "Apply pending PG migrations to a target DB"
row "nix run .#migrate-gpkg"    "Apply pending GPKG migrations to a target file"
row "nix run .#docs"            "Regenerate Schema Reference in docs/data-model/*.md"
row "nix run .#release"         "Cut a release: --bump X --commit (PR), then --tag after merge"

section "📚" "Documentation site (mkdocs-material)"
row "nix run .#docs-serve"   "Live preview at http://127.0.0.1:8000"
row "nix run .#docs-build"   "Strict build into ./site (CI parity)"

section "🗺️ " "Apps"
row "nix run .#qgis"         "QGIS with the InfrastructureMapper profile"
row "nix run .#qgis-ltr"     "QGIS LTR with the same profile"
row "./scripts/vscode.sh"    "VSCode with the project workspace"

printf '\n%sMade with 💗 by Kartoza%s\n\n' "$PG_C_DIM" "$PG_C_RESET"
