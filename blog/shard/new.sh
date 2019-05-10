#!/bin/bash
# script to shard the collection 'messages' in database 'cloud'
# This is currently for three shards with three members each
# one config server with three members

#need to change the "localhost" to theb ip

#instantiate the config server
#ssh into config
ssh dan@34.74.106.7 << !

sudo killall mongod
sudo killall mongos
sudo killall mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1

sudo mongod --configsvr --replSet configReplSet --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,router --fork --logpath /var/log/mongodb.log

#Initiate replica set 
mongo config:27017 << 'EOF'

	config = { _id: "configReplSet", configsvr: true, members:[
	          { _id : 0, host : "10.128.0.4:27017" }]};
	rs.initiate(config);

EOF

!

#Creating Shard 1
ssh dan@35.231.161.115 << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 

sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log

#Initiate replica set 
mongo shard1:27017 << 'EOF'

	rs.initiate({ _id: "shardReplSet6", members:[
	          { _id : 0, host : "10.142.0.9:27017" },
	          { _id : 1, host : "10.142.0.9:27018" }]});

EOF

!g