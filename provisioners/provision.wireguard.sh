#!/bin/bash 

echo "Setting Up Wireguard"
echo "Setting hostname"
sudo hostnamectl set-hostname bugmenace 
echo '127.0.0.1 bugmeance' | sudo tee -a /etc/hosts 
echo 'bugmenace' | sudo tee /etc/hostname 
echo "Adding repo" 
printf "\n" | sudo add-apt-repository ppa:wireguard/wireguard -y 
echo "Updating" 
sudo apt-get update 
echo "Installing" 
sudo apt-get install -y wireguard-dkms wireguard-tools  ;
echo "Networking stuff" 
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf 
echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.conf 
sudo sysctl -p 
echo "WG stuff" 
sudo apt install dnsmasq openresolv -y 
wg genkey | sudo tee /etc/wireguard/privkey | wg pubkey | sudo tee /etc/wireguard/pubkey > /dev/null
wg genkey | sudo tee /etc/wireguard/peerprivkey | wg pubkey | sudo tee /etc/wireguard/peerpubkey > /dev/null
echo "Generating wg0.conf" 
echo '[Interface]' | sudo tee /etc/wireguard/wg0.conf
echo 'Address = 10.200.200.1/24' | sudo tee -a /etc/wireguard/wg0.conf
echo 'ListenPort = 36283' | sudo tee -a /etc/wireguard/wg0.conf
echo "PrivateKey = $(sudo cat /etc/wireguard/privkey | tr -d '\r\n')" | sudo tee -a /etc/wireguard/wg0.conf > /dev/null
echo 'DNS = 208.67.222.222,208.67.220.22' | sudo tee -a /etc/wireguard/wg0.conf
echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; systemctl restart dnsmasq' | sudo tee -a /etc/wireguard/wg0.conf
echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; systemctl restart dnsmasq' | sudo tee -a /etc/wireguard/wg0.conf

echo '' | sudo tee -a /etc/wireguard/wg0.conf
echo '[Peer]' | sudo tee -a /etc/wireguard/wg0.conf
echo "PublicKey = $(sudo cat /etc/wireguard/peerpubkey | tr -d '\r\n')" | sudo tee -a /etc/wireguard/wg0.conf
echo 'AllowedIPs = 10.200.200.2/32' | sudo tee -a /etc/wireguard/wg0.conf

sudo chmod 640 /etc/wireguard/wg0.conf 
sudo chmod 640 /etc/wireguard/privkey 
sudo chmod 640 /etc/wireguard/peerprivkey 

echo "DNS stuff" 
sudo mkdir -p /etc/systemd/resolved.conf.d;
printf "[Resolve]\nDNSStubListener=no\n" | sudo tee /etc/systemd/resolved.conf.d/noresolved.conf 
sudo systemctl restart systemd-resolved 
sudo rm /etc/resolv.conf 
sudo touch /etc/resolv.conf 
echo 'name_servers="127.0.0.1"' | sudo tee /etc/resolvconf.conf 
echo 'dnsmasq_conf=/etc/dnsmasq-openresolv.conf' | sudo tee -a /etc/resolvconf.conf 
echo 'dnsmasq_resolv=/etc/dnsmasq-resolv.conf' | sudo tee -a /etc/resolvconf.conf 
echo 'conf-file=/etc/dnsmasq-openresolv.conf' | sudo tee -a /etc/dnsmasq.conf 
echo 'resolv-file=/etc/dnsmasq-resolv.conf' | sudo tee -a /etc/dnsmasq.conf 
sudo systemctl start dnsmasq 
sudo systemctl enable dnsmasq 
sudo systemctl start wg-quick@wg0 
sudo systemctl enable wg-quick@wg0 
sudo systemctl restart dnsmasq


echo "Wireguard Setup Complete"