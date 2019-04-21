#!/bin/bash
# script to shard the collection 'test' in database 'cloud'
# This is currently for one shard with three members
# one config server

#cleanup

killall mongod
killall mongos
killall mongo

rm -rf /data/config
rm -rf /data/shard*

#create necessary directories
mkdir -p /data/config
mkdir -p /data/shard0/rs0 /data/shard0/rs1 /data/shard0/rs2
mkdir -p /data/shard1/rs0 /data/shard1/rs1 /data/shard1/rs2
mkdir -p /data/shard2/rs0 /data/shard2/rs1 /data/shard2/rs2


#instantiate the config server
mongod --configsvr --replSet csrs0 --dbpath /data/config --fork --port 47017 --logpath /var/log/csrs0.log

#Initiate replica set 
mongo --port 47017 << 'EOF'

config = { _id: "csrs0", configsvr: true, members:[
          { _id : 0, host : "localhost:47017" }]};
rs.initiate(config);

EOF


#create shard replica sets
mongod --shardsvr --replSet s0 --dbpath /data/shard0/rs0 --fork --port 37017 --logpath /var/log/s0r0.log
mongod --shardsvr --replSet s0 --dbpath /data/shard0/rs1 --fork --port 37018 --logpath /var/log/s0r1.log
mongod --shardsvr --replSet s0 --dbpath /data/shard0/rs2 --fork --port 37019 --logpath /var/log/s0r2.log


#Initiate replica set 
mongo --port 37017 << 'EOF'

config = { _id: "s0", members:[
          { _id : 0, host : "localhost:37017" },
          { _id : 1, host : "localhost:37018" },
          { _id : 2, host : "localhost:37019" }]};
rs.initiate(config);


EOF

#Connect mongos

mongos --configdb localhost:47017 --fork --port 57017 --logpath /var/log/mongos.log

#run mongo instant on port that mongos is listening to
mongo --host localhost --port 57017 << 'EOF'

sh.addShard("s0/localhost:37017")
sh.addShard("s0/localhost:37018")
sh.addShard("s0/localhost:37019")


sh.enableSharding("cloud")
sh.shardCollection("cloud.test", { _id : true} )
EOF
