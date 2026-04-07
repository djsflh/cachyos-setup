#!/bin/bash
echo "--- Configuring UFW ---"

echo "  → Installing packages..." | tee -a "$LOGFILE"
run_quiet "Installing ufw packages" sudo pacman -Sy --noconfirm ufw >> "$LOGFILE" 2>&1

# Enable UFW if not already
sudo ufw --force enable

# Allow SSH only from your trusted IP
sudo ufw allow from 192.168.1.51 to any port 22 proto tcp

sudo systemctl enable ufw
sudo systemctl start ufw

sudo ufw status verbose
echo "UFW configured."
