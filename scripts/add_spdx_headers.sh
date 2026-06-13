#!/usr/bin/env bash
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
set -euo pipefail

AUTHOR="Tim Sutton"
LICENSE="MIT"

# REUSE-IgnoreStart
# The strings below contain literal SPDX prefixes that this script emits into
# other files. They are not declarations about THIS file's licensing — REUSE
# is told to ignore them via the IgnoreStart/IgnoreEnd markers.
COPY_TAG="SPDX-FileCopyrightText"
LIC_TAG="SPDX-License-Identifier"
# REUSE-IgnoreEnd

add_header() {
  local file="$1"
  local comment

  # Skip binary files
  if grep -qIl . "$file"; then
    # Choose comment syntax. JSON has no comment grammar at all and is
    # covered by REUSE.toml instead. CSS uses /* */, not <!-- -->.
    case "$file" in
      *.json) echo "ℹ️  Skipping $file — JSON has no comment syntax; covered by REUSE.toml." >&2; return ;;
      *.py|*.sh|*.yaml|*.yml|*.txt|*.conf|*.toml|*.nix|*.env) comment="#" ;;
      *.sql) comment="--" ;;
      *.css) comment="/*" ;;
      *.md|*.html) comment="<!--" ;;
      *) echo "⚠️  Unknown comment style for $file. Skipping." >&2; return ;;
    esac

    # Skip if already tagged
    if grep -q "${LIC_TAG}:" "$file"; then
      echo "✅ $file already tagged"
      return
    fi

    echo "➕ Adding header to $file"

    # Add header in the comment grammar for this file type.
    case "$comment" in
      "<!--")
        { echo "<!-- ${COPY_TAG}: $AUTHOR -->"
          echo "<!-- ${LIC_TAG}: $LICENSE -->"
          cat "$file"
        } > "$file.new"
        ;;
      "/*")
        { echo "/* ${COPY_TAG}: $AUTHOR */"
          echo "/* ${LIC_TAG}: $LICENSE */"
          cat "$file"
        } > "$file.new"
        ;;
      *)
        { echo "$comment ${COPY_TAG}: $AUTHOR"
          echo "$comment ${LIC_TAG}: $LICENSE"
          cat "$file"
        } > "$file.new"
        ;;
    esac

    mv "$file.new" "$file"
  fi
}

export -f add_header

# Find all files and check against .gitignore dynamically
find . \
  -type f \
  ! -path "./.git/*" \
  ! -path "./LICENSES/*" \
  ! -path "./.reuse/*" \
  ! -name "*.license" \
  -print0 | while IFS= read -r -d '' file; do
    # Use git check-ignore to see if file should be ignored per .gitignore
    if git check-ignore -q "$file" 2>/dev/null; then
      echo "🚫 Skipping ignored file: $file"
      continue
    fi

    add_header "$file"
  done
