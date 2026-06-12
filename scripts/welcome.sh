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

# Kartoza palette (hex; mapped to ANSI 24-bit by gum/terminal).
KZ_FOREST="#2F5D50"
KZ_MOSS="#7C9C75"
KZ_TEAL="#2B7A78"
KZ_SAND="#E0D2B2"
KZ_LEAF="#C1E1C1"

VERSION="$(tr -d '[:space:]' < "$PG_REPO_ROOT/VERSION" 2>/dev/null || echo unknown)"

pg_status_chip() {
    case "$(pg_state)" in
        running)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "$KZ_LEAF" --bold "● RUNNING"
            else
                printf '%s● RUNNING%s' "$PG_C_GREEN" "$PG_C_RESET"
            fi
            ;;
        stopped)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "$KZ_SAND" --bold "● STOPPED"
            else
                printf '%s● STOPPED%s' "$PG_C_YELLOW" "$PG_C_RESET"
            fi
            ;;
        uninitialized)
            if command -v gum >/dev/null 2>&1; then
                gum style --foreground "#D87171" --bold "● NOT INITIALIZED"
            else
                printf '%s● NOT INITIALIZED%s' "$PG_C_RED" "$PG_C_RESET"
            fi
            ;;
    esac
}

print_banner_gum() {
    gum style \
        --border rounded \
        --border-foreground "$KZ_TEAL" \
        --foreground "$KZ_FOREST" \
        --padding "1 3" --margin "1 0" \
        --bold \
        "🌐  Infrastructure Mapper  v$VERSION" \
        "$(gum style --faint --foreground "$KZ_MOSS" "Spatial schema + GeoPackage pipeline · Kartoza")"
}

print_banner_plain() {
    printf '\n%s═══ Infrastructure Mapper · v%s ═══%s\n' \
        "$PG_C_BOLD" "$VERSION" "$PG_C_RESET"
    printf '%sSpatial schema + GeoPackage pipeline · Kartoza%s\n\n' \
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
row "nix run .#build-gpkg"   "Build gpkg/KartozaInfrastructureMapper.gpkg (--crs EPSG:NNNN)"
row "nix run .#migrate-pg"   "Apply pending PG migrations to a target DB"
row "nix run .#migrate-gpkg" "Apply pending GPKG migrations to a target file"
row "nix run .#docs"         "Regenerate Schema Reference in docs/data-model/*.md"
row "nix run .#release"      "Cut a release (--bump patch|minor|major --commit)"

section "📚" "Documentation site (mkdocs-material)"
row "nix run .#docs-serve"   "Live preview at http://127.0.0.1:8000"
row "nix run .#docs-build"   "Strict build into ./site (CI parity)"

section "🗺️ " "Apps"
row "nix run .#qgis"         "QGIS with the InfrastructureMapper profile"
row "nix run .#qgis-ltr"     "QGIS LTR with the same profile"
row "./scripts/vscode.sh"    "VSCode with the project workspace"

printf '\n%sMade with 💗 by Kartoza%s\n\n' "$PG_C_DIM" "$PG_C_RESET"
