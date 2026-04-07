#!/bin/bash
echo "--- Installing QEMU/KVM ---"

run_quiet "Installing QEMU packages" sudo pacman -Sy --noconfirm qemu-full virt-manager swtpm >> "$LOGFILE" 2>&1

# Fix firewall backend so libvirt works with UFW
run_quiet "Setting firewall backend" echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf

# Enable libvirt daemon and socket
run_quiet "Enabling libvirtd"  sudo systemctl enable --now libvirtd.service
sudo systemctl enable --now libvirtd.socket

# Add user to libvirt and kvm groups
sudo usermod -aG libvirt,kvm "$USER"

# Allow VM network traffic through UFW
sudo ufw route allow from 192.168.122.0/24

# Enable default NAT network
sudo virsh net-autostart default
sudo virsh net-start default 2>/dev/null || true

echo "QEMU installed. Log out and back in for group changes to take effect."
