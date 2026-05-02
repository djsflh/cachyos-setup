#!/bin/bash
set -e

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$BACKUP"
    echo "===Plasma backup created==="

    # Find the [Containments][23][Applets][28][General] section and add shownItems if not present
    if grep -q "\[Containments\]\[23\]\[Applets\]\[28\]\[General\]" "$CONFIG"; then
        if ! grep -A 5 "\[Containments\]\[23\]\[Applets\]\[28\]\[General\]" "$CONFIG" | grep -q "shownItems="; then
            # Add the line after the section header
            sed -i '/\[Containments\]\[23\]\[Applets\]\[28\]\[General\]/a shownItems=org.kde.plasma.battery' "$CONFIG"
            echo "===Configured battery applet to always show in the panel. Restart Plasma to apply changes.==="
        else
            echo "===Battery applet already configured to show in the panel.==="
        fi
    else
        echo "===Warning: Could not find [Containments][23][Applets][28][General] section.==="
    fi
else
    echo "===Warning: plasma-org.kde.plasma.desktop-appletsrc not found.==="
fi
