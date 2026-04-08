#!/bin/bash

# ── Snapper home config ───────────────────────────────────────────
echo
if sudo snapper list-configs | grep -q "^home "; then
    echo "Snapper home config already exists, skipping."
    echo
else
    echo "Creating snapper config for /home"
    sudo snapper -c home create-config /home
    echo
fi

echo "Disabling timeline snapshots for home config"
sudo snapper -c home set-config "TIMELINE_CREATE=no"
echo

# ── snap-pac.ini ──────────────────────────────────────────────────
SNAPFILE="/etc/snap-pac.ini"

if ! sudo grep -q "^\s*\[home\]" "$SNAPFILE" 2>/dev/null; then
    printf '\n[home]\n snapshot = True\n' | sudo tee -a "$SNAPFILE" > /dev/null
    echo "Added [home] config to $SNAPFILE"
else
    echo "[home] config already exists in $SNAPFILE, skipping."
fi
echo
