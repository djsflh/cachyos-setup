#!/bin/bash

# ── Snapper home config ───────────────────────────────────────────
if sudo snapper list-configs | grep -q "^home "; then
    echo "===Snapper [home] config already exists, skipping==="
else
    sudo snapper -c home create-config /home
    echo "===Snapper [home] config created==="
fi

sudo snapper -c home set-config "TIMELINE_CREATE=no"
echo "===Disabled timeline snapshots for Snapper [home] config==="

# ── snap-pac.ini ──────────────────────────────────────────────────
SNAPFILE="/etc/snap-pac.ini"

if ! sudo grep -q "^\s*\[home\]" "$SNAPFILE" 2>/dev/null; then
    printf '\n[home]\n snapshot = True\n' | sudo tee -a "$SNAPFILE" > /dev/null
    echo "===Enabled snap-pac snapshots for Snapper [home] config==="
else
    echo "===Snap-pac snapshots for Snapper [home] config already enabled, skipping==="
fi
