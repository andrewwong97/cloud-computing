#!/bin/bash
# script to shard the collection 'messages' in database 'cloud'
# This is currently for three shards with three members each
# one config server with three members

#need to change the "localhost" to theb ip

#cleanup


if [ "$1" != "" ]; then
    usr="$1"
else
    echo "Positional Paramater 1 should contain username for ssh"
    exit 1
fi


router="$usr@104.196.191.234"
shard2="$usr34.74.10.88"
shard3="$usr@104.196.191.234"
shard4="$usr@104.196.106.11"
shard5="$usr@104.196.106.12"
shard6="$usr@104.196.106.13"


#instantiate the config server
#ssh into config
ssh -t $router << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1

sudo mongod --configsvr --replSet configReplSet --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,router --fork --logpath /var/log/mongodb.log

#Initiate replica set 
mongo << 'EOF'

	config = { _id: "configReplSet", configsvr: true, members:[
	          { _id : 0, host : "10.128.0.4:27017" }]};

	rs.initiate({ _id: "configReplSet", configsvr: true, members:[
	          { _id : 0, host : "10.142.0.20:27017" }]});

EOF

!

#Creating Shard 1
ssh -t $shard1 << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 

sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet1 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard1 --fork  --logpath /var/log/mongodb.log

#Initiate replica set 
mongo << 'EOF'

	rs.initiate({ _id: "shardReplSet1", members:[
	          { _id : 0, host : "10.142.0.9:27017" },
	          { _id : 1, host : "10.142.0.9:27018" }]});

EOF

!


#Creating Shard 2
ssh -t $shard2 << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 

sudo mongod --shardsvr --replSet shardReplSet2 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard2 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet2 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard2 --fork  --logpath /var/log/mongodb.log

#Initiate replica set 
mongo << 'EOF'

	rs.initiate({ _id: "shardReplSet2", members:[
	          { _id : 0, host : "10.142.0.10:27017" },
	          { _id : 1, host : "10.142.0.10:27018" }]});

EOF

!

#Creating Shard 3
ssh -t $shard3 << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 

sudo mongod --shardsvr --replSet shardReplSet3 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard3 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet3 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard3 --fork  --logpath /var/log/mongodb.log

#Initiate replica set 
mongo << 'EOF'

	rs.initiate({ _id: "shardReplSet3", members:[
	          { _id : 0, host : "10.142.0.8:27017" },
	          { _id : 1, host : "10.142.0.8:27018" }]});

EOF

!

#Creating Shard 4
ssh -t $shard4 << !

sudo pkill mongod
sudo pkill mongos
sudo pkill mongo
sudo rm -rf /data/rs*
sudo mkdir -p /data/rs1 /data/rs2 

sudo mongod --shardsvr --replSet shardReplSet4 --dbpath /data/rs1 --port 27017 --bind_ip 127.0.0.1,shard4 --fork  --logpath /var/log/mongodb.log
sudo mongod --shardsvr --replSet shardReplSet4 --dbpath /data/rs2 --port 27018 --bind_ip 127.0.0.1,shard4 --fork  --logpath /var/log/mongodb.log

#Initiate replica set 
mongo shard1:27017 << 'EOF'

	rs.initiate({ _id: "shardReplSet4", members:[
	          { _id : 0, host : "10.142.0.10:27017" },
	          { _id : 1, host : "10.142.0.10:27018" }]});

EOF

!

#Connect mongos
ssh -t $router << !


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


sh.enableSharding("cloud")
sh.shardCollection("cloud.messages", { _id : "hashed"} )
EOF

!