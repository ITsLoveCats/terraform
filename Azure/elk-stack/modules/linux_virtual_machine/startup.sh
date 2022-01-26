#!/bin/bash

# elasticsearch stack
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt install apt-transport-https -y

echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update && sudo apt install elasticsearch -y

sudo systemctl enable --now elasticsearch.service

sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

sudo systemctl restart elasticsearch.service


# kibana Stack
sudo apt-get update && sudo apt-get install kibana

sudo systemctl enable --now kibana.service

# nginx reverse proxy
sudo apt install nginx -y

sudo systemctl enable --now nginx