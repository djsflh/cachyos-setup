#!/bin/bash

sudo pacman -S --noconfirm nano-syntax-highlighting
echo "===nano-syntax-highlighting installed==="

LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'

# User nanorc
NANORC="$HOME/.nanorc"
if ! grep -qF "$LINE" "$NANORC" 2>/dev/null; then
    echo "$LINE" >> "$NANORC"
    echo "===Added nano syntax highlighting to ~/.nanorc==="
else
    echo "===nano syntax highlighting already configured in ~/.nanorc, skipping==="
fi

# Root nanorc (for sudo nano)
if ! sudo grep -qF "$LINE" /root/.nanorc 2>/dev/null; then
    echo "$LINE" | sudo tee -a /root/.nanorc > /dev/null
    echo "===Added nano syntax highlighting to /root/.nanorc==="
else
    echo "===nano syntax highlighting already configured in /root/.nanorc, skipping==="
fi
