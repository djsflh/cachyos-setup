#!/bin/bash

echo
echo "Installing grsync"

echo
echo "   sudo pacman -Sy --noconfirm grsync"
run_quiet "Installing grsync" sudo pacman -Sy --noconfirm grsync >> "$LOGFILE" 2>&1

echo
echo "grsync installed."
