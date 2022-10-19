#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive;

echo "Installing sudo nfs-common portmap rsync";
sudo apt-get install sudo nfs-common portmap rsync curl -y;

echo "Installing qemu-guest-agent spice-vdagent";
sudo apt-get install qemu-guest-agent spice-vdagent -y;

sudo systemctl enable spice-vdagent || true;
sudo systemctl enable spice-vdagentd || true;
