#!/bin/bash

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install dirmgr -y
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo mkdir /data
sudo mkdir /data/db
sudo echo '10.142.0.2	hadoop' >> /etc/hosts
sudo echo '10.128.0.3	router' >> /etc/hosts
sudo echo '10.128.0.4	config' >> /etc/hosts
sudo echo '10.128.0.5	shard1' >> /etc/hosts
sudo echo '10.128.0.6	shard2' >> /etc/hosts
sudo echo '10.142.0.8	shard3' >> /etc/hosts
