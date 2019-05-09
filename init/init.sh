#!/bin/bash

sudo mkdir /data
sudo mkdir /data/db
sudo echo '10.142.0.2	hadoop' >> /etc/hosts
sudo echo '10.128.0.3	router' >> /etc/hosts
sudo echo '10.128.0.4	config' >> /etc/hosts
sudo echo '10.128.0.5	shard1' >> /etc/hosts
sudo echo '10.128.0.6	shard2' >> /etc/hosts
sudo echo '10.142.0.8	shard3' >> /etc/hosts