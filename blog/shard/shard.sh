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
config1 << !

sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 /data/rs3

sudo mongod --configsvr --replSet configReplSet --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log
sudo mongod --configsvr --replSet configReplSet --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log
sudo mongod --configsvr --replSet configReplSet --dbpath /data/rs3 --port 27019 --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log

#Initiate replica set 
mongo config:27017 << 'EOF'

	config = { _id: "configReplSet", configsvr: true, members:[
	          { _id : 0, host : "10.128.0.4:27017" },
	          { _id : 1, host : "10.128.0.4:27018" },
	          { _id : 2, host : "10.128.0.4:27019" }]};
	rs.initiate(config);

EOF

!

#Creating Shard 1
shard1 << !

sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 /data/rs3

sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs3 --port 27019 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log


#Initiate replica set 
mongo shard1:27017 << 'EOF'

	config = { _id: "shardReplSet1", members:[
	          { _id : 0, host : "10.128.0.5:27017" },
	          { _id : 1, host : "10.128.0.5:27018" },
	          { _id : 2, host : "10.128.0.5:27019" }]};
	rs.initiate(config);

EOF

!

#Creating Shard 1
shard2 << !

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

sudo mongos --configdb configReplSet/config:27017 -port 27017 --bind_ip 127.0.0.1,router --fork --logpath /var/log/mongos.log

#run mongo instant on port that mongos is listening to
mongo --host router --port 27020 << 'EOF'

sh.addShard("shardReplSet1/10.128.0.5:27017")
sh.addShard("shardReplSet1/10.128.0.5:27018")
sh.addShard("shardReplSet1/10.128.0.5:27019")

sh.addShard("shardReplSet2/10.128.0.6:27017")
sh.addShard("shardReplSet2/10.128.0.6:27018")
sh.addShard("shardReplSet2/10.128.0.6:27019")


sh.enableSharding("cloud")
sh.shardCollection("cloud.messages", { _id : "hashed"} )
EOF

!


