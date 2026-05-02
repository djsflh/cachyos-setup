#!/bin/bash

# https://wiki.cachyos.org/virtualization/qemu_and_vmm_setup/

sudo pacman -S --noconfirm qemu-full
echo "===QEMU installed==="

sudo pacman -S --noconfirm virt-manager
echo "===virt-manager installed==="

sudo pacman -S --noconfirm swtpm
echo "===swtpm installed==="

echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf > /dev/null 2>&1
echo "===Forced libvirt to use iptables==="

sudo usermod -aG libvirt "$USER"
echo "===Added the user to the libvirt group so they can use it==="

sudo systemctl enable --now libvirtd.service
echo "===Enabled LXC backend==="

sudo systemctl enable --now libvirtd.socket
echo "===Enabled QEMU backend==="

sudo virsh net-autostart default
echo "===Configured to bring internet up in a VM whenever one starts==="

sudo ufw route allow from 192.168.122.0/24
echo "===Allowed VM network traffic through UFW==="

echo "===QEMU configuration complete. Log out and back in for group changes to take effect.==="
