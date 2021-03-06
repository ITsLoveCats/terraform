#!/bin/bash


# elasticsearch stack
# -------------------
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt install apt-transport-https -y

echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update && sudo apt install elasticsearch -y

sudo systemctl enable --now elasticsearch.service

sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "xpack.security.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "xpack.security.authc.api_key.enabled: true" >> /etc/elasticsearch/elasticsearch.yml

# Create Superuser
/usr/share/elasticsearch/bin/elasticsearch-users useradd kibanaadmin -p plaintextpassword -r superuser

# Create user with kibana_system role
/usr/share/elasticsearch/bin/elasticsearch-users useradd mykibanasystem -p plaintextpassword -r kibana_system

sudo systemctl restart elasticsearch.service


# kibana Stack
# ------------
sudo apt-get update && sudo apt-get install kibana

echo "elasticsearch.username: "mykibanasystem"" >> /etc/kibana/kibana.yml

# add secure mykibanasystem password to kibana keystore
printf "plaintextpassword"| /usr/share/kibana/bin/kibana-keystore add elasticsearch.password -x

#/usr/share/kibana/bin/kibana-keystore create -s

sudo systemctl enable --now kibana.service


# nginx reverse proxy
# -------------------
sudo apt install nginx -y

sudo systemctl enable --now nginx

# basic authen pass through
echo "kibanaadmin:`openssl passwd -1 "plaintextpassword"`"  | sudo tee -a /etc/nginx/htpasswd.users

curl https://raw.githubusercontent.com/ITsLoveCats/terraform/main/Azure/elk-stack/modules/linux_virtual_machine/kibana.conf >> kibana.conf
sudo mv kibana.conf /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/kibana.conf /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default

sudo systemctl restart nginx