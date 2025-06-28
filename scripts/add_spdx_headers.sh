#!/usr/bin/env bash
set -euo pipefail

AUTHOR="Tim Sutton"
LICENSE="MIT"

add_header() {
  local file="$1"
  local comment

  # Skip binary files
  if grep -qIl . "$file"; then
    # Choose comment syntax
    case "$file" in
      *.py|*.sh|*.yaml|*.yml|*.txt|*.conf|*.toml|*.nix|*.env|*.json) comment="#" ;;
      *.sql) comment="--" ;;
      *.md|*.css|*.html) comment="<!--" ;;
      *) echo "⚠️  Unknown comment style for $file. Skipping." >&2; return ;;
    esac

    # Skip if already tagged
    if grep -q "SPDX-License-Identifier:" "$file"; then
      echo "✅ $file already tagged"
      return
    fi

    echo "➕ Adding header to $file"

    # Add correct syntax (special case for block comments like HTML)
    if [[ "$comment" == "<!--" ]]; then
      {
        echo "<!-- SPDX-FileCopyrightText: $AUTHOR -->"
        echo "<!-- SPDX-License-Identifier: $LICENSE -->"
        cat "$file"
      } > "$file.new"
    else
      {
        echo "$comment SPDX-FileCopyrightText: $AUTHOR"
        echo "$comment SPDX-License-Identifier: $LICENSE"
        cat "$file"
      } > "$file.new"
    fi

    mv "$file.new" "$file"
  fi
}

export -f add_header

# Find all files except in .git, .reuse, LICENSES, etc.
find . \
  -type f \
  ! -path "./.git/*" \
  ! -path "./LICENSES/*" \
  ! -path "./.reuse/*" \
  ! -name "*.license" \
  ! -name "*.png" \
  ! -name "*.gif" \
  ! -name "*.qgz" \
  -exec bash -c 'add_header "$0"' {} \;

