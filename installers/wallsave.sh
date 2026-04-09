#!/bin/bash
set -e

# Helper for cleaner output
run_quiet() {
    echo "=== $1 ==="
    shift
    "$@" >/dev/null 2>&1 || true
}

echo
run_quiet "Installing qt5-tools" sudo pacman -S --needed qt5-tools
echo

echo "=== Creating ~/Pictures/saved directory ==="
echo
mkdir -p ~/Pictures/saved

echo "=== Creating wallsave script ==="
echo
											  
cat > /tmp/wallsave.tmp << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.wallpaper 0 | grep "Image: file:" | cut -c 15-)

# Remove surrounding quotes if present
WALLPAPER=$(echo "$WALLPAPER" | sed 's/^"//;s/"$//')

# Use the original filename (overwrites if same name already exists)
FILENAME=$(basename "$WALLPAPER")
DEST="$HOME/Pictures/saved/$FILENAME"

# Copy silently
cp "$WALLPAPER" "$DEST" 2>/dev/null || true
EOF

sudo tee /usr/bin/wallsave < /tmp/wallsave.tmp >/dev/null														 
sudo chmod +x /usr/bin/wallsave
rm -f /tmp/wallsave.tmp
echo

echo "=== Creating desktop shortcut ==="
cat > ~/Desktop/Save\ Current\ Wallpaper.desktop << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper using original filename
Exec=wallsave
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x ~/Desktop/Save\ Current\ Wallpaper.desktop
echo	

echo "The script is not installed.  Run with: wallsave"
echo "or double-click the desktop icon"
