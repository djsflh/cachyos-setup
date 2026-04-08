#!/bin/bash

echo
echo "Installing openssh"
echo "   sudo pacman -Sy --noconfirm openssh"
run_quiet "Installing openssh" sudo pacman -Sy --noconfirm openssh >> "$LOGFILE" 2>&1
echo

echo "Enabling sshd"
echo "   sudo systemctl enable sshd"
sudo systemctl enable sshd
echo

echo "Starting sshd"
echo "   sudo systemctl start sshd"
sudo systemctl start sshd
echo

echo "Allowing 192.168.1.51 in firewall"
echo "   sudo ufw allow from 192.168.1.51 to any port 22 proto tcp"
sudo ufw allow from 192.168.1.51 to any port 22 proto tcp
echo

echo "SSH enabled and started."
