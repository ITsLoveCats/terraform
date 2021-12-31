#!/bin/bash

## Step 1. Wireguard VPN Server ##

# Step 1 – Update your system
sudo apt update
sudo apt upgrade -y

# Step 2 – Installing a WireGuard VPN server on Ubuntu 20.04 LTS
sudo apt install wireguard -y

# Step 3 - Configuring Firewall ufw 
ufw allow 51820/udp

apt install resolvconf
