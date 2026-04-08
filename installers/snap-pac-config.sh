#!/bin/bash
echo "--- Configuring snap-pac.ini ---"

SNAPFILE="/etc/snap-pac.ini"

if ! sudo grep -q "^\s*\[home\]" "$SNAPFILE" 2>/dev/null; then
    printf '\n[home]\n snapshot = True\n' | sudo tee -a "$SNAPFILE" > /dev/null
    echo "Added [home] config to $SNAPFILE"
else
    echo "[home] config already exists in $SNAPFILE, skipping."
fi
