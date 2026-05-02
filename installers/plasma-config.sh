#!/bin/bash
set -e

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [ ! -f "$CONFIG" ]; then
    echo "===Warning: plasma-org.kde.plasma.desktop-appletsrc not found.==="
    exit 1
fi

cp "$CONFIG" "$BACKUP"
echo "===Plasma backup created==="

kwriteconfig6 \
    --file plasma-org.kde.plasma.desktop-appletsrc \
    --group "Containments" --group "23" \
    --group "Applets" --group "28" \
    --group "General" \
    --key "shownItems" \
    "org.kde.plasma.battery"

echo "===Configured battery applet to always show in the panel. Restart Plasma to apply changes.==="