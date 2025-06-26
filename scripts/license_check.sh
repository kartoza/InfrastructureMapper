#!/usr/bin/env bash

# 🤖 Add a shell hook that ensures that each file (sql, shell script, python module)
# declares the license, copyright and includes a link to kartoza.com

missing=0
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(py|sh|sql)$"); do
    if ! grep -qi "copyright" "$file" || ! grep -qi "license" "$file" || ! grep -qi "kartoza.com" "$file"; then
        echo "$file is missing required license/copyright/Kartoza link"
        missing=1
    fi
done
exit $missing
