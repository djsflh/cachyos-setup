#!/bin/bash

sudo pacman -S --noconfirm openssh
echo "===OpenSSH installed==="

sudo systemctl enable --now sshd
echo "===SSH service enabled and started==="

sudo ufw allow from 192.168.1.51 to any port 22 proto tcp
echo "===Created UFW rule for 192.168.1.51==="

echo "===SSH setup complete.==="
