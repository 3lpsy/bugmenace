#!/bin/sh -eux


export DEBIAN_FRONTEND=noninteractive;

echo "Provisioning: Wireguard Client Setup - Starting"

echo "Provisioning: Wireguard Client Setup - Installing OpenResolv"

sudo apt-get install openresolv -y

WG_CONF=$(cat << EOF
[Interface]
Address = 10.200.200.2/24
PrivateKey = YYYY
DNS = 10.200.200.1

[Peer]
PublicKey = XXXX
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = AAAA:BBBB
PersistentKeepalive = 21

EOF
)

echo "Provisioning: Wireguard Client Setup - Creating Example Conf"
echo "$WG_CONF" | sudo tee /etc/wireguard/wg0.conf.example

echo "Provisioning: Wireguard Client Setup - Complete"
