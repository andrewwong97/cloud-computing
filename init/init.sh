#!/bin/bash

sudo rm -rf /etc/hosts
sudo echo '127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters


10.128.0.8	single
10.142.0.9	hadoope1
10.128.0.10	hadoopc1
10.142.0.20	router
10.142.0.9	shard1
10.142.0.10	shard2
10.142.0.8	shard3
10.142.0.11	shard4
10.142.0.12	shard5
10.142.0.13	shard6 
10.142.0.8	shard7' >> /etc/hosts
