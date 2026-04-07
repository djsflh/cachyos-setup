#!/bin/bash
echo "--- Installing QEMU/KVM ---"

sudo pacman -Sy --noconfirm \
    qemu-desktop \
    virt-manager \
    libvirt \
    dnsmasq \
    bridge-utils \
    vde2 \
    openbsd-netcat \
    ebtables \
    iptables

# Enable and start libvirt daemon
sudo systemctl enable --now libvirtd

# Add your user to the libvirt and kvm groups
sudo usermod -aG libvirt,kvm "$USER"

# Enable default network autostart
sudo virsh net-autostart default
sudo virsh net-start default 2>/dev/null || true

echo "QEMU installed. NOTE: Log out and back in for group changes to take effect."
