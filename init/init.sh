#!/bin/bash

sudo mkdir /data
sudo mkdir /data/db
sudo echo '10.128.0.4	config
10.150.0.2	hadoop
10.128.0.3	router
10.142.0.9	shard1
10.142.0.10	shard2
10.142.0.8	shard3
10.142.0.11	shard4
10.142.0.12	shard5
10.142.0.13	shard6
10.142.0.14	shard7
10.142.0.15	shard8' >> /etc/hosts
