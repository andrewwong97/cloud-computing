#!/bin/bash
# script to shard the collection 'messages' in database 'cloud'
# This is currently for three shards with three members each
# one config server with three members

#need to change the "localhost" to theb ip

#cleanup

sudo killall mongod
sudo killall mongos
sudo killall mongo

#instantiate the config server
#ssh into config
sudo ssh dan@34.74.106.7 << !

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

!

#Creating Shard 1
shard2 << !

sudo killall mongod
sudo killall mongos
sudo killall mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 /data/rs3

sudo mongod --shardsvr --replSet shardReplSet2 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet2 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet2 --dbpath /data/rs3 --port 27019 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log


#Initiate replica set 
mongo shard2:27017 << 'EOF'

	config = { _id: "shardReplSet2", members:[
	          { _id : 0, host : "10.128.0.6:27017" },
	          { _id : 1, host : "10.128.0.6:27018" },
	          { _id : 2, host : "10.128.0.6:27019" }]};
	rs.initiate(config);

EOF

!

#Connect mongos
router << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo mongos --configdb configReplSet/router:27017 -port 27018 --bind_ip 127.0.0.1,router --fork --logpath /var/log/mongos.log

#run mongo instant on port that mongos is listening to
mongo --host router --port 27017 << 'EOF'


sh.addShard("shardReplSet1/10.142.0.9:27017")
sh.addShard("shardReplSet1/10.142.0.9:27018")

sh.addShard("shardReplSet2/10.142.0.10:27017")
sh.addShard("shardReplSet2/10.142.0.10:27018")

sh.addShard("shardReplSet3/10.142.0.8:27017")
sh.addShard("shardReplSet3/10.142.0.8:27018")

sh.addShard("shardReplSet4/10.142.0.11:27017")
sh.addShard("shardReplSet4/10.142.0.11:27018")

sh.addShard("shardReplSet5/10.142.0.12:27017")
sh.addShard("shardReplSet5/10.142.0.12:27018")

sh.addShard("shardReplSet6/10.142.0.13:27017")
sh.addShard("shardReplSet6/10.142.0.13:27018")


sh.enableSharding("cloud")
sh.shardCollection("cloud.messages", { _id : "hashed"} )
EOF

!

