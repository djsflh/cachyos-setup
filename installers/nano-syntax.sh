#!/bin/bash
echo "--- Installing nano syntax highlighting ---"

sudo pacman -Sy --noconfirm nano-syntax-highlighting

# Activate it — append to nanorc if not already there
NANORC="$HOME/.nanorc"
LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'

if ! grep -qF "$LINE" "$NANORC" 2>/dev/null; then
    echo "$LINE" >> "$NANORC"
    echo "Added nano syntax highlighting to ~/.nanorc"
else
    echo "nano syntax highlighting already configured"
fi
