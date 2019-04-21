# Cloud Computing Final Project


# Cluster Setup

Using default Debian 9 node in Google Cloud Compute Engine with 3.75 GB of memory and 1 vCPU. 

## Reference

**Aliases Used**

`hadoop` - server used for Hadoop chained MR

`router` - app router that receives db queries and talks to config servers for shard to get data from 

`shard1` - shard server 1

`shard2` - shard server 2

`config1` - holds metadata about shards and shard lookup table


**Architecture**

1 mongos router, 1 config server, 2 shard servers. Each running with the same amount of resources for now, using hashing as the sharding strategy.

As long as you are ssh'ed into a node with the private cluster, then connecting to the database is simple. Each node should have Mongo set up already, so you can use the `mongo` client by running `mongo router:27017/cloud` to access the sharded collection, and `mongo router:27017/single` to access the non-sharded collection. Similarly, a database connection string would look like: `mongodb://router:27017/cloud`. 

![image](https://user-images.githubusercontent.com/7339169/56473300-2f3cbf80-6437-11e9-811f-ce7a4fc50ef5.png)

Each node in the private cluster also has the following `/etc/hosts` file to quickly look up other hosts in the cluster.
```
10.142.0.2	hadoop
10.128.0.3	router
10.128.0.5	shard1
10.128.0.6	shard2
10.128.0.4	config
```


## New Mongo Server Setup
If you want to create your own cluster, please follow the directions below. 

Adapted from MongoDB documentation: [https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/) 

**Run these commands in order for each Mongo node**
1. `sudo apt-get update && sudo apt-get upgrade` 
2. `sudo apt-get install dirmngr -y`
3. `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4`
4. `echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list`
5. `sudo apt-get update`
6. `sudo apt-get install -y mongodb-org`
7. Make sure `/data` exists, if not, create the directory.

7. Append to `/etc/hosts`. This allows us to reference private IPs using aliases in server set up. Replace with your own private IPs if you are using your own cluster configuration.
```
10.142.0.2	hadoop
10.128.0.3	router
10.128.0.5	shard1
10.128.0.6	shard2
10.128.0.4	config
```

**Next, create config server, shard server, and router servers (in order)**

## 1. for config server only

Directions adapted from here: [mongod — MongoDB Manual](https://docs.mongodb.com/manual/reference/program/mongod/#sharded-cluster-options)

1. `mkdir /data/configdb/`

2. `sudo mongod --configsvr --replSet configReplSet --dbpath /data/configdb --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log`

Execute this in ONE config server only (primary replica)
3. Enter mongo shell: `mongo config:27019`
`rs.initiate( { _id: "configReplSet", configsvr: true, members: [ { _id: 0, host: "config:27019" }] } )`

## 2. for shard server only

First make sure `/data/db/` exists in all shard servers before you execute the below
1. ssh into shard1 server: `sudo mongod --shardsvr --replSet shardReplSet1  --dbpath /data/db --bind_ip localhost,shard1 --fork --logpath /var/log/mongodb.log`
	- run  `sudo mongo shard1:27018` and `rs.initiate()` in the mongo shell to initiate the replica set
2. Do the same for shard2 server: `sudo mongod --shardsvr --replSet shardReplSet2  --dbpath /data/db --bind_ip localhost,shard2 --fork --logpath /var/log/mongodb.log`
	- run  `sudo mongo shard2:27018` and `rs.initiate()` in the mongo shell to initiate the replica set

Shard ids: `shardReplSet1`,  `shardReplSet2`

## 3. for router server only
Best practice: for each MR client node, run a single instance of `mongos` , which interfaces query routing.

### Create Router Server and Sharding Config

1. Start the mongos daemon: `sudo mongos --configdb configReplSet/config:27019 --bind_ip localhost,router --fork --logpath /var/log/mongodb.log`
2. Log into mongos: `mongo router:27017`
3. First execute `use cloud` to create database if haven’t created already
4. To add replica shards from step 2 to the cluster, run these commands, one for each replica shard until everything is added.  `sh.addShard("shardReplSet1/shard1:27018")`, `sh.addShard("shardReplSet2/shard2:27018")`
5. Enable sharding on the db `sh.enableSharding("cloud")`
6. Choose `hashed` sharding strategy and collection to shard `sh.shardCollection("cloud.messages", { _id: "hashed" })`

### Data Ingress
1. `git clone https://github.com/andrewwong97/cloud-computing.git`
2. `pip install bson`
3. `cd cloud-computing/mapreduce`
4. Outside of mongo shell run: `mongoimport --db cloud --collection messages --file data.json --jsonArray`
5. Inside of mongo shell (`mongo router:27017`) run `db.messages.getShardDistribution()` to check that sharding has worked successfully.


## Redis (Debian 9)
Configure cache size: max memory, policy
`sudo vim /etc/redis/redis.conf`

`sudo systemctl restart redis-server.service`

How to use Redis as an LRU cache:   [https://redis.io/topics/lru-cache](https://redis.io/topics/lru-cache) 

Installation notes:   [https://tecadmin.net/install-redis-on-debian-9-stretch/](https://tecadmin.net/install-redis-on-debian-9-stretch/) 

## Hadoop - Chained MapReduce
As a simple initial test, we create 2^10 random samples of key, message pairs as would be found in or database, and pipes it to the mapper and reducer: `./test_mapreduce.sh`
