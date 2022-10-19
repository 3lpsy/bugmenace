#!/bin/bash

set -e;

if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    SUDOER="ubuntu"
else
    SUDOER="vagrant"
fi

export DEBIAN_FRONTEND=noninteractive;
echo "Installing some utilities"
sudo apt-get install -y git unzip p7zip-full vim mlocate tmux whois nmap jq awscli dnsutils;

sudo apt-get install -y python3-all python3-pip
