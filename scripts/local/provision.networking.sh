#!/bin/bash

set -e;

# multline variables weren't working
echo "source /etc/network/interfaces.d/*" | sudo tee /etc/network/interfaces
echo "auto lo" | sudo tee -a /etc/network/interfaces
echo "iface lo inet loopback" | sudo tee -a /etc/network/interfaces
echo "auto eth0" | sudo tee -a /etc/network/interfaces
echo "iface eth0 inet dhcp" | sudo tee -a /etc/network/interfaces
