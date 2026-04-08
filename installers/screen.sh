#!/bin/bash

echo
run_quiet "Installing screen packages" sudo pacman -Sy --noconfirm screen >> "$LOGFILE" 2>&1

echo "Screen installed."
