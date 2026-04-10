#!/bin/bash
set -e

# Helper for cleaner output
run_quiet() {
    echo "=== $1 ==="
    shift
    "$@" >/dev/null 2>&1 || true
}

echo
echo "=== Modifying Plasma Configuration ==="
echo

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$BACKUP"
    echo
    echo "Backup created: $BACKUP"
    echo
    # Find the [Containments][23][Applets][28][General] section and add shownItems if not present
    if grep -q "\[Containments\]\[23\]\[Applets\]\[28\]\[General\]" "$CONFIG"; then
        if ! grep -A 5 "\[Containments\]\[23\]\[Applets\]\[28\]\[General\]" "$CONFIG" | grep -q "shownItems="; then
            # Add the line after the section header
            sed -i '/\[Containments\]\[23\]\[Applets\]\[28\]\[General\]/a shownItems=org.kde.plasma.battery' "$CONFIG"
            echo "Added shownItems=org.kde.plasma.battery to [Containments][23][Applets][28][General]"
        else
            echo
            echo "shownItems already exists in the configuration."
        fi
    else
        echo
        echo "Warning: Could not find [Containments][23][Applets][28][General] section."
    fi
else
    echo
    echo "Warning: plasma-org.kde.plasma.desktop-appletsrc not found."
fi
echo

echo "=== Restarting plasma-plasmashell service ==="
systemctl --user restart plasma-plasmashell.service

echo
echo "=== Configuration complete! ==="