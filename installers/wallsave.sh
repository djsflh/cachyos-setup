#!/bin/bash
set -e

echo "=== Creating ~/Pictures/saved directory ==="
echo
mkdir -p "$HOME/Pictures/saved"

echo "=== Creating wallsave script ==="

mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/wallsave" << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')

FILENAME=$(basename "$WALLPAPER")
DEST="$HOME/Pictures/saved/$FILENAME"

cp "$WALLPAPER" "$DEST" 2>/dev/null || true
EOF

chmod +x "$HOME/.local/bin/wallsave"
echo

echo "=== Installing .desktop application to ~/.local/share/applications/ ==="
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/Save Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper
Exec=wallsave
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$HOME/.local/share/applications/Save Current Wallpaper.desktop"
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
