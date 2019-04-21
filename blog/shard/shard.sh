#!/bin/bash
# script to shard the collection 'messages' in database 'cloud'
# This is currently for three shards with three members each
# one config server with three members

#need to change the "localhost" to theb ip

#cleanup

killall mongod
killall mongos
killall mongo

rm -rf /data/configdb*
rm -rf /data/shard*

#create necessary directories
mkdir -p /data/configdb/rs1 /data/configdb/rs2 /data/configdb/rs3
mkdir -p /data/shard1/rs1 /data/shard1/rs2 /data/shard1/rs3
mkdir -p /data/shard2/rs1 /data/shard2/rs2 /data/shard2/rs3

#Change the following to desired ip
HADOOP=127.0.0.1
ROUTER=127.0.0.1
SHARD1=127.0.0.1
SHARD2=127.0.0.1
CONFIG=127.0.0.1


#instantiate the config server
mongod --configsvr --replSet configReplSet --dbpath /data/configdb/rs1 --port 27017 --bind_ip 127.0.0.1,$CONFIG --fork --logpath /var/log/mongodb.log
mongod --configsvr --replSet configReplSet --dbpath /data/configdb/rs2 --port 27018 --bind_ip 127.0.0.1,$CONFIG --fork --logpath /var/log/mongodb.log
mongod --configsvr --replSet configReplSet --dbpath /data/configdb/rs3 --port 27019 --bind_ip 127.0.0.1,$CONFIG --fork --logpath /var/log/mongodb.log

#Initiate replica set 
mongo $CONFIG:27017 << 'EOF'

config = { _id: "configReplSet", configsvr: true, members:[
          { _id : 0, host : "localhost:27017" },
          { _id : 1, host : "localhost:27018" },
          { _id : 2, host : "localhost:27019" }]};
rs.initiate(config);

EOF


#Creating Shard 1
mongod --shardsvr --replSet shardReplSet1 --dbpath /data/shard1/rs1 --port 37017 --bind_ip 127.0.0.1,$SHARD1 --fork  --logpath /var/log/mongodb.log
mongod --shardsvr --replSet shardReplSet1 --dbpath /data/shard1/rs2 --port 37018 --bind_ip 127.0.0.1,$SHARD1 --fork  --logpath /var/log/mongodb.log
mongod --shardsvr --replSet shardReplSet1 --dbpath /data/shard1/rs3 --port 37019 --bind_ip 127.0.0.1,$SHARD1 --fork  --logpath /var/log/mongodb.log


#Initiate replica set 
mongo $SHARD1:37017 << 'EOF'

config = { _id: "shardReplSet1", members:[
          { _id : 0, host : "localhost:37017" },
          { _id : 1, host : "localhost:37018" },
          { _id : 2, host : "localhost:37019" }]};
rs.initiate(config);

EOF

#Creating Shard 2
mongod --shardsvr --replSet shardReplSet2 --dbpath /data/shard2/rs1 --port 47017 --bind_ip 127.0.0.1,$SHARD2 --fork  --logpath /var/log/mongodb.log
mongod --shardsvr --replSet shardReplSet2 --dbpath /data/shard2/rs2 --port 47018 --bind_ip 127.0.0.1,$SHARD2 --fork  --logpath /var/log/mongodb.log
mongod --shardsvr --replSet shardReplSet2 --dbpath /data/shard2/rs3 --port 47019 --bind_ip 127.0.0.1,$SHARD2 --fork  --logpath /var/log/mongodb.log


#Initiate replica set 
mongo $SHARD2:47017 << 'EOF'

config = { _id: "shardReplSet2", members:[
          { _id : 0, host : "localhost:47017" },
          { _id : 1, host : "localhost:47018" },
          { _id : 2, host : "localhost:47019" }]};
rs.initiate(config);

EOF

#Connect mongos

mongos --configdb configReplSet/$CONFIG:27017 --port 27020 --bind_ip 127.0.0.1,$ROUTER --fork --logpath /var/log/mongos.log

#run mongo instant on port that mongos is listening to
mongo --host $ROUTER --port 27020 << 'EOF'

sh.addShard("shardReplSet1/localhost:37017")
sh.addShard("shardReplSet1/localhost:37018")
sh.addShard("shardReplSet1/localhost:37019")

sh.addShard("shardReplSet2/localhost:47017")
sh.addShard("shardReplSet2/localhost:47018")
sh.addShard("shardReplSet2/localhost:47019")


sh.enableSharding("cloud")
sh.shardCollection("cloud.messages", { _id : "hashed"} )
EOF
