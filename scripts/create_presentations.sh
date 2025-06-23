#!/usr/bin/env bash

PRESENTATION_DIR="./presentations"
THEME="./presentation/slide-style.css"

for mdfile in "$PRESENTATION_DIR"/*.md; do
    echo "Processing $mdfile"
    if [[ -f "$mdfile" ]]; then
        marp "$mdfile" --theme "$THEME"
    fi
done
