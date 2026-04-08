#!/bin/bash

run_quiet "Installing nano-syntax packages" sudo pacman -Sy --noconfirm nano-syntax-highlighting

LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'

# User nanorc
NANORC="$HOME/.nanorc"
if ! grep -qF "$LINE" "$NANORC" 2>/dev/null; then
    echo "$LINE" >> "$NANORC"
    echo "Added nano syntax highlighting to ~/.nanorc"
else
    echo "nano syntax highlighting already configured in ~/.nanorc"
fi

# Root nanorc (for sudo nano)
if ! sudo grep -qF "$LINE" /root/.nanorc 2>/dev/null; then
    echo "$LINE" | sudo tee -a /root/.nanorc > /dev/null
    echo "Added nano syntax highlighting to /root/.nanorc"
else
    echo "nano syntax highlighting already configured in /root/.nanorc"
fi
