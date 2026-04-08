#!/bin/bash

run_quiet "Installing nano-syntax packages" sudo pacman -Sy --noconfirm nano-syntax-highlighting >> "$LOGFILE" 2>&1

# Activate it — append to nanorc if not already there
NANORC="$HOME/.nanorc"
LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'

if ! grep -qF "$LINE" "$NANORC" 2>/dev/null; then
    echo "$LINE" >> "$NANORC"
    echo
    echo "Added nano syntax highlighting to ~/.nanorc"
else
    echo
    echo "nano syntax highlighting already configured"
fi
