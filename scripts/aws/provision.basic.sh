#!/bin/sh -eux

set -e;

echo "Provisioning: Base - Start"
echo "Provisioning: Base - Updating Repos"
export DEBIAN_FRONTEND=noninteractive;

echo "Provisioning: Base - Cleaning"
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
echo "Provisioning: Base - Updating Repo 1"
sudo DEBIAN_FRONTEND=noninteractive apt update
echo "Provisioning: Base - Updating Upgrading"
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
echo "Provisioning: Base - Updating Repo 2"
sudo DEBIAN_FRONTEND=noninteractive apt update
echo "Provisioning: Base - Updating Upgrading Distro"
sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y;
echo "Provisioning: Base - Updating Repo 3"
sudo DEBIAN_FRONTEND=noninteractive apt update
echo "Provisioning: Base - Cleaning 2"
sudo DEBIAN_FRONTEND=noninteractive apt-get clean

echo "Provisioning: Base - Updating Repo 4"
sudo DEBIAN_FRONTEND=noninteractive apt update
echo "Provisioning: Base - Autoremoving"
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

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