#!/bin/bash
# Scan dotfiles to guess external command dependencies.
# Usage: analyze-dependencies.sh <path-to-dotfiles>

set -e

DIR="${1:-configs}"

if [ ! -d "$DIR" ]; then
    echo "Directory $DIR not found" >&2
    exit 1
fi

# Grep for patterns like 'exec program', 'ExecStart=program', or 'command program'
# Then extract the program name and deduplicate.

grep -RohE '\b(exec|ExecStart|command)\s+[^\s;]+' "$DIR" |
    sed -E 's/.*\b(exec|ExecStart|command)\s+//' |
    cut -d' ' -f1 |
    cut -d'/' -f1 |
    sort -u
