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

echo "=== Installing .desktop application to ~/.local/share/applications/ ==="
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/Save\ Current\ Wallpaper.desktop << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper using original filename
Exec=wallsave
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x ~/.local/share/applications/Save\ Current\ Wallpaper.desktop
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
        if ! grep -q "Save Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Save Current Wallpaper.desktop|' "$CONFIG"
			echo
            echo "Added launcher to task manager."
        else
            echo
			echo "'Save Current Wallpaper' already exists in favorites."
        fi
    else
		echo	
        echo "Warning: Could not find launchers= line.  "
    fi
else
	echo	
    echo "Warning: plasma-org.kde.plasma.desktop-appletsrc not found."
fi
echo

echo "=== Restarting plasma-plasmashell service ==="
systemctl --user restart plasma-plasmashell.service
	   
					

echo
echo "=== Installation complete! ==="
echo
echo "Run with: wallsave"
echo "or click the shortcut in the task manager (taskbar)"
