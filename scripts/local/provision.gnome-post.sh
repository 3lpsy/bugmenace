#!/bin/bash

# xfce4 doesn't work well with spice (guest tools in libvirt), use gnome for now
# need to make sure lightdm is not there

set -e;

export DEBIAN_FRONTEND=noninteractive;

echo "Updating package repositories";
sudo apt-get update

echo "Setting gdm3 as default display manager pre-answer"
echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager
sudo systemctl disable lightdm || echo "Issue with: systemctl disable lightdm";

echo "Purging lightdm just in case"
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";

echo "Purging bdm3 just in case"\
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y gdm3 || echo "Issue with: apt-get purge -y gdm3";

echo "Setting gdm3 as default display manager pre-answer"
echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager

echo "Installing gdm3"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gdm3;

sudo systemctl enable gdm3;
sudo systemctl start gdm3;