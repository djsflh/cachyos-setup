#!/bin/bash
set -e

echo "=== Creating walldelete script ==="

cat > /tmp/walldelete.tmp << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.wallpaper 0 | grep "Image: file:" | cut -c 15-)

# Remove surrounding quotes if present
WALLPAPER=$(echo "$WALLPAPER" | sed 's/^"//;s/"$//')

if [[ -z "$WALLPAPER" ]]; then
    echo "Could not determine current wallpaper path."
    exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
    echo "File not found: $WALLPAPER"
    exit 1
fi

echo "Deleting: $WALLPAPER"
rm "$WALLPAPER"
echo "Deleted."
EOF

sudo tee /usr/bin/walldelete < /tmp/walldelete.tmp >/dev/null
sudo chmod +x /usr/bin/walldelete
rm -f /tmp/walldelete.tmp
echo

echo "=== Installing .desktop application to ~/.local/share/applications/ ==="
mkdir -p ~/.local/share/applications
cat > "$HOME/.local/share/applications/Delete Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Delete Current Wallpaper
Comment=Delete the current KDE Plasma wallpaper
Exec=walldelete
Icon=user-trash
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$HOME/.local/share/applications/Delete Current Wallpaper.desktop"
echo

echo "=== Adding Launcher to Plasma Task Manager ==="
CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$BACKUP"
    echo "Backup created: $BACKUP"
    echo

    if grep -q "launchers=" "$CONFIG"; then
        if ! grep -q "Delete Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Delete Current Wallpaper.desktop|' "$CONFIG"
            echo "Added launcher to task manager."
        else
            echo "'Delete Current Wallpaper' already exists in favorites."
        fi
    else
        echo "Warning: Could not find launchers= line."
    fi
else
    echo "Warning: plasma-org.kde.plasma.desktop-appletsrc not found."
fi
echo

echo "=== Restarting plasma-plasmashell service ==="
systemctl --user restart plasma-plasmashell.service

echo
echo "=== Installation complete! ==="
echo
echo "Run with: walldelete"
echo "or click the shortcut in the task manager (taskbar)"
