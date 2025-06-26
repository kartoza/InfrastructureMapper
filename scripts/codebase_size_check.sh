#!/usr/bin/env bash

# 🤖 Add a hook that calculates the number of lines change and gives
# the committer encouragement if they reduced the size of the code
# base whilst gently admonishing them if they grew it

added=$(git diff --cached --numstat | awk '{add+=$1} END {print add}')
removed=$(git diff --cached --numstat | awk '{del+=$2} END {print del}')
net=$((added - removed))
if [ "$net" -lt 0 ]; then
    echo "🎉 Great job! You reduced the codebase by $((-net)) lines!"
elif [ "$net" -gt 0 ]; then
    echo "⚠️ You increased the codebase by $net lines. Please keep it lean!"
else
    echo "No net change in code size. Keep up the steady work!"
fi
exit 0
