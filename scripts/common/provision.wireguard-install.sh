#!/bin/bash

set -e;

export DEBIAN_FRONTEND=noninteractive;

echo "Provisioning: Installing Wireguard - Start"

if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    echo "Provisioning: Installing Wireguard - Adding Repo"
    printf "\n" | sudo add-apt-repository ppa:wireguard/wireguard -y 
    echo "Provisioning: Installing Wireguard - Updating Repo"
    sudo apt-get update 
    echo "Provisioning: Installing Wireguard - Installing"
    sudo apt-get install -y wireguard-dkms wireguard-tools
else
    echo "Provisioning: Installing Wireguard - Installing"
    sudo apt-get install -y wireguard;
fi
echo "Provisioning: Installing Wireguard - Complete"
