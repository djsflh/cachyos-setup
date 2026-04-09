#!/bin/bash
set -e

echo "=== Installing qt5-tools (if needed) ==="
sudo pacman -S --needed qt5-tools

echo "=== Creating ~/Pictures/saved directory ==="
mkdir -p ~/Pictures/saved

echo "=== Creating silent wallsave script ==="
cat > ~/.local/bin/wallsave << 'EOF'
#!/bin/bash

# Silent wallpaper saver for KDE Plasma 6
WALLPAPER=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.wallpaper 0 | grep "Image: file:" | cut -c 15-)

# Clean up quotes if present
WALLPAPER=$(echo "$WALLPAPER" | sed 's/^"//;s/"$//')

# Get original filename extension and save silently (overwrites if exists)
FILENAME="current_wallpaper$(echo "$WALLPAPER" | sed 's/.*\./\./')"
DEST="$HOME/Pictures/saved/$FILENAME"

cp "$WALLPAPER" "$DEST" 2>/dev/null || true
EOF

chmod +x ~/.local/bin/wallsave

echo "=== Updating desktop shortcut ==="
cat > ~/Desktop/Save\ Current\ Wallpaper.desktop << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper silently
Exec=wallsave
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x ~/Desktop/Save\ Current\ Wallpaper.desktop

echo "=== Installation complete! ==="
echo ""
echo "wallsave is now completely silent."
echo "It will always save as ~/Pictures/saved/current_wallpaper.<extension>"
echo "and will overwrite the previous file without any messages."
echo ""
echo "You can run it with: wallsave"
echo "or by clicking the desktop icon."
