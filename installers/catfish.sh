#!/bin/bash

echo
echo "Installing catfish + dependencies"

echo
echo "   sudo pacman -Sy --noconfirm catfish"
run_quiet "Installing catfish + dependencies" sudo pacman -Sy --noconfirm catfish >> "$LOGFILE" 2>&1

echo
echo "catfish installed."
