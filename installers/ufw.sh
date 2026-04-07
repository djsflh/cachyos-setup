#!/bin/bash
echo "--- Configuring UFW ---"

sudo pacman -Sy --noconfirm ufw

# Enable UFW if not already
sudo ufw --force enable

# Allow SSH only from your trusted IP
sudo ufw allow from 192.168.1.51 to any port 22 proto tcp

sudo systemctl enable ufw
sudo systemctl start ufw

sudo ufw status verbose
echo "UFW configured."
