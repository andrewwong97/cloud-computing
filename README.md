# Cloud Computing Final Project


# Cluster Setup

Using default Debian 9 node in Google Cloud Compute Engine with 3.75 GB of memory and 1 vCPU. Shard nodes: 1.7 GB of memory, 1 vCPU.

## Reference

**Aliases Used**

`hadoop` - server used for Hadoop chained MR

`router` - app router that receives db queries and talks to config servers for shard to get data from 

`shard1` - shard server 1

`shard2` - shard server 2

`shardN`  - shard server N

`config` - holds metadata about shards and shard lookup table


**Architecture**

1 mongos router, 1 config server, 2 shard servers. Each running with the same amount of resources for now, using hashing as the sharding strategy.

As long as you are ssh'ed into a node with the private cluster, then connecting to the database is simple. Each node should have Mongo set up already, so you can use the `mongo` client by running `mongo router:27017/cloud` to access the sharded collection, and `mongo router:27017/single` to access the non-sharded collection. Similarly, a database connection string would look like: `mongodb://router:27017/cloud`. 

![image](https://user-images.githubusercontent.com/7339169/56473300-2f3cbf80-6437-11e9-811f-ce7a4fc50ef5.png)

Each node in the private cluster should also have the following `/etc/hosts` file to quickly look up other hosts in the cluster.
```
10.128.0.4	config
10.150.0.2	hadoop
10.128.0.3	router
10.142.0.9	shard1
10.142.0.10	shard2
10.142.0.8	shard3
10.142.0.11	shard4
10.142.0.12	shard5
10.142.0.13	shard6
10.142.0.14	shard7
10.142.0.15	shard8
```

**TIP:**
Add this to your bashrc file to easily ssh into the servers:
```
35.245.187.84	hadoop
35.225.61.34	router
35.238.87.99	config
35.231.161.115	shard1
34.74.10.88	shard2
104.196.191.234	shard3
104.196.106.11	shard4
35.196.142.43	shard5
34.73.238.145	shard6
35.237.151.254	shard7
34.73.245.126	shard8
```

## New Mongo Server Setup - see `init/` for scripted setup
If you want to create your own cluster, please follow the directions below. 

Adapted from MongoDB documentation: [https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/) 

**Run these commands in order for each Mongo node**
1. `sudo apt-get update && sudo apt-get upgrade` 
2. `sudo apt-get install dirmngr -y`
3. `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4`
4. `echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list`
5. `sudo apt-get update`
6. `sudo apt-get install -y mongodb-org`
7. Make sure `/data` exists, if not, create the directory. Also create `/data/db`

8. Append to `/etc/hosts`. This allows us to reference private IPs using aliases in server set up. Replace with your own private IPs if you are using your own cluster configuration.
```
10.128.0.4	config
10.150.0.2	hadoop
10.128.0.3	router
10.142.0.9	shard1
10.142.0.10	shard2
10.142.0.8	shard3
10.142.0.11	shard4
10.142.0.12	shard5
10.142.0.13	shard6
10.142.0.14	shard7
10.142.0.15	shard8
```

**Next, create config server, shard server, and router servers (in order)**

## 1. for config server only

Directions adapted from here: [mongod — MongoDB Manual](https://docs.mongodb.com/manual/reference/program/mongod/#sharded-cluster-options)

1. `mkdir /data && mkdir /data/configdb/`

2. `sudo mongod --configsvr --replSet configReplSet --dbpath /data/configdb --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log`

Execute this in ONE config server only (primary replica)
3. Enter mongo shell: `mongo config:27019`
`rs.initiate( { _id: "configReplSet", configsvr: true, members: [ { _id: 0, host: "config:27019" }] } )`

## 2. for shard server only

First make sure `/data/db/` exists in all shard servers before you execute the below
1. SSH into each shard server and run: `sudo mongod --shardsvr --replSet <REPL_SET_NAME>  --dbpath /data/db --bind_ip localhost,<SHARD_ALIAS> --fork --logpath /var/log/mongodb.log`
	- run  `sudo mongo <SHARD_ALIAS>:27018` and `rs.initiate()` in the mongo shell to initiate the replica set

Shard alias: `shard1`, `shard2`, etc.
Shard repl set name: `shardReplSet1`,  `shardReplSet2`, etc.


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

1. `sudo apt-get install redis-server -y`
2. `sudo systemctl enable redis-server.service`
3. `sudo systemctl start redis-server.service`

4. To configure cache size: max memory, policy
`sudo vim /etc/redis/redis.conf`

Add these two lines to conf:
```
maxmemory 256mb
maxmemory-policy allkeys-lru
```

5. To access cli, run `redis-cli`

Adapted from: 
- How to use Redis as an LRU cache:   [https://redis.io/topics/lru-cache](https://redis.io/topics/lru-cache) 
- Installation notes:   [https://tecadmin.net/install-redis-on-debian-9-stretch/](https://tecadmin.net/install-redis-on-debian-9-stretch/) 

## Hadoop - Chained MapReduce
As a simple initial test, we create 2^10 random samples of key, message pairs as would be found in or database, and pipes it to the mapper and reducer: `./test_mapreduce.sh`
