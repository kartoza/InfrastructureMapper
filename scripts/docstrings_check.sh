# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
#!/usr/bin/env bash

# 🤖 Add a check that ensures that any python modules updated
# have docstrings in google docstring format for every method,
# function and class.

missing=0
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E "\.py$"); do
    if ! which darglint >/dev/null 2>&1; then
        echo "darglint not on PATH. Run inside 'nix develop' (or 'nix develop .#minimal')."
        exit 1
    fi
    if ! output=$(darglint --docstring-style=google "$file" 2>&1); then
        echo "Docstring check failed for: $file"
        echo "$output"
        missing=1
    fi
done
exit $missing
