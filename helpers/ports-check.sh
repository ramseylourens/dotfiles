#!/usr/bin/env zsh
# Verifies that every port in config/macports.txt exists in the MacPorts index.
# Usage: helpers/ports-check.sh [file]

file="${1:-${0:A:h}/../config/macports.txt}"
missing=0

while read -r name _; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if ! /opt/local/bin/port info --name --line "$name" &>/dev/null; then
        echo "Missing port: $name"
        missing=$((missing + 1))
    fi
done < "$file"

if (( missing )); then
    echo "$missing port(s) not found"
    exit 1
fi
echo "All ports found"
