#!/bin/bash

set -e;

echo "Provisioning: Base - Start"
echo "Provisioning: Base - Updating Repos"
export DEBIAN_FRONTEND=noninteractive;

sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y;
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove

echo "Provisioning: Base - Installing Base Packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git apt-transport-https ca-certificates curl software-properties-common python3

sudo hostnamectl set-hostname bugmenace
echo -n "bugmenace" | sudo tee /etc/hostname;
echo "127.0.0.1 bugmenace" | sudo tee -a /etc/hosts
# sudo systemctl stop systemd-resolved
# sudo systemctl disable systemd-resolved
# sudo rm /etc/resolv.conf

# echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "Provisioning: Base - Complete"