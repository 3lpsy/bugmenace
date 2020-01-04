#!/bin/bash

set -e;

INTERFACES=$(cat << EOF 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp


EOF 
)

echo "$INTERFACES" | sudo tee /etc/network/interfaces