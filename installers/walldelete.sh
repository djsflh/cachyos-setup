#!/bin/bash
set -e

echo "=== Creating walldelete script ==="

cat > "$HOME/.local/bin/walldelete" << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')

echo "Deleting: $WALLPAPER"
rm "$WALLPAPER"
echo "Deleted."
EOF

chmod +x "$HOME/.local/bin/wallsave"
echo

echo "=== Installing .desktop application to ~/.local/share/applications/ ==="
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/Delete Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Delete Current Wallpaper
Comment=Delete the current KDE Plasma wallpaper
Exec=$HOME/.local/bin/walldelete
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
    echo
    echo "Backup created: $BACKUP"
    # Find the launchers line and append the new entry if not already present
    if grep -q "launchers=" "$CONFIG"; then
        if ! grep -q "Delete Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Delete Current Wallpaper.desktop|' "$CONFIG"
            echo "Added launcher to task manager."
        else
            echo "'Delete Current Wallpaper' already exists in favorites."
        fi
    else
        echo "Warning: Could not find launchers= line.  "
    fi
else
    echo "Warning: plasma-org.kde.plasma.desktop-appletsrc not found."
fi
echo

echo "=== Adding Keyboard Shortcut Alt + D ==="

cat > "$HOME/.config/kglobalshortcutsrc" << 'EOF'
[Delete Current Wallpaper.desktop]
_k_friendly_name=Delete Current Wallpaper
_launch=Alt+D,none,$HOME/.local/bin/walldelete
EOF

chmod +x "$HOME/.local/bin/wallsave"
echo

echo "=== Restarting plasma-plasmashell service ==="
systemctl --user restart plasma-plasmashell.service

echo
echo "=== Installation complete! ==="
echo
echo "Run with: walldelete"
echo "or click the shortcut in the task manager (taskbar)"
