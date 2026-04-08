#!/bin/bash

echo
echo "Installing screen"

echo
echo "   sudo pacman -Sy --noconfirm screen"
run_quiet "Installing screen" sudo pacman -Sy --noconfirm screen >> "$LOGFILE" 2>&1

echo
echo "Screen installed."
