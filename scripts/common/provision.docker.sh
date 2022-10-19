#!/bin/bash

set -e;


if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    SUDOER="ubuntu"
else
    SUDOER="vagrant"
fi

export DEBIAN_FRONTEND=noninteractive;

if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    echo "Provisioning: Docker - Start"
    echo "Provisioning: Docker - Adding Docker Repo Key"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "Provisioning: Docker - Adding Docker Repo"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

else
    echo "Provisioning: Docker - Start"
    echo "Provisioning: Docker - Adding Docker Repo Key"
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo "Provisioning: Docker - Adding Docker Repo"
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian bullseye stable' | sudo tee /etc/apt/sources.list.d/docker.list
fi

echo "Provisioning: Docker - Updating Repos"
sudo apt update
sudo apt-cache policy docker-ce
echo "Provisioning: Docker - Installing Docker"
sudo apt install -y docker-ce
sudo systemctl status docker
echo "Provisioning: Docker - Enabling Docker"
sudo systemctl enable docker
echo "Provisioning: Docker - Adding ${SUDOER} to 'docker' group"
sudo usermod -aG docker ${SUDOER}
echo "Provisioning: Docker - Complete"
