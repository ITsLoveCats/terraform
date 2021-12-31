#!/bin/bash

## Step 1. Wireguard VPN Server ##

# Update your system
sudo apt update
sudo apt upgrade -y

# Installing a WireGuard VPN server on Ubuntu 20.04 LTS
sudo apt install wireguard -y

# Configuring Firewall ufw 
ufw allow 51820/udp
ufw status

# IP Forwarding
# set /etc/sysctl.conf net.ipv4.ip_forward=1
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Apply the new option.
sudo sysctl -p /etc/sysctl.conf

# Generate Server Key
cd /etc/wireguard/
mkdir Serverkeys && cd Serverkeys

umask 077 
wg genkey | tee privatekey | wg pubkey > publickey


# wg0 Server Config 
:'
script to run
'

echo "
[Interface]
Address = 10.200.200.1/24
SaveConfig = true 

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

ListenPort = 51820 

PrivateKey=$(cat /etc/wireguard/Serverkeys/privatekey)" | sudo tee /etc/wireguard/wg0.conf

## Step 2. Generate Client Config ##

# Generate Clients Key
cd /etc/wireguard/
mkdir Clientskeys && cd Clientskeys

umask 077 
wg genkey | tee ClientA_privatekey | wg pubkey > ClientA_publickey

# Generate Client Config
mkdir -p /etc/wireguard/ClientsConfig/ClientA/

echo "[Interface] #ClientA
Address = 10.200.200.2/32
PrivateKey = $(cat '/etc/wireguard/Clientskeys/ClientA_privatekey')
DNS = 1.1.1.1 # Cloudflare DNS but you can use DNS of your choice

[Peer]
PublicKey = $(cat '/etc/wireguard/Serverkeys/publickey')
Endpoint = <your_vpnServer_address>
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" > /etc/wireguard/ClientsConfig/ClientA/wg0.conf

pip=$(curl ifconfig.me)
sed -i "s/<your_vpnServer_address>/$pip:51820/g" /etc/wireguard/ClientsConfig/ClientA/wg0.conf

## Step 3. Append Client to Server Config ##
echo "
[Peer]
## ClientA 
PublicKey = $(cat '/etc/wireguard/Clientskeys/ClientA_publickey')
 
## client VPN IP address (note  the /32 subnet) 
AllowedIPs = 10.200.200.2/32" | sudo tee -a /etc/wireguard/wg0.conf


# Start and Enable WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

## Step 4. QR code (Optional) ##
apt install qrencode -y