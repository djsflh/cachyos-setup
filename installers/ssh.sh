#!/bin/bash
echo "--- Enabling SSH ---"

echo "  → Installing packages..." | tee -a "$LOGFILE"
run_quiet "Installing ssh packages" sudo pacman -Sy --noconfirm openssh >> "$LOGFILE" 2>&1

sudo systemctl enable sshd
sudo systemctl start sshd

echo "SSH enabled and started."
