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

Each node in the private cluster should also have the following `/etc/hosts` file to quickly look up other hosts in the cluster.
```
10.128.0.8	single
10.142.0.19	hadoop-large-e1
10.128.0.9	hadoop-c1
10.142.0.20	router
10.142.0.9	shard1 <-- corrupted
10.142.0.10	shard2
10.142.0.8	shard3
10.142.0.11	shard4
10.142.0.12	shard5
10.142.0.13	shard6
10.142.0.21 	shard7
```

**TIP:**
Add this to your bashrc file to easily ssh into the servers. Note: some of these may have changed in cluster reconfigurations.
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

Run `bash init/install.sh` then run `bash init/init.sh`

# Next, create config server, shard server, and router servers (in order)

## 1. Config Server

Directions adapted from here: [mongod — MongoDB Manual](https://docs.mongodb.com/manual/reference/program/mongod/#sharded-cluster-options)

1. `mkdir /data && mkdir /data/configdb/`

2. `sudo mongod --configsvr --replSet configReplSet --dbpath /data/configdb --bind_ip 127.0.0.1,config --fork --logpath /var/log/mongodb.log`

Execute this in ONE config server only (primary replica) This is used to tell mongo where the config servers are.


3. Enter mongo shell: `mongo config:27019`
`rs.initiate( { _id: "configReplSet", configsvr: true, members: [ { _id: 0, host: "config:27019" }] } )`

## 2. Shard Server(s)

First make sure `/data/db/` exists in all shard servers before you execute the below
1. SSH into each shard server and run: `sudo mongod --shardsvr --replSet <REPL_SET_NAME>  --dbpath /data/db --bind_ip localhost,<SHARD_ALIAS> --fork --logpath /var/log/mongodb.log`
	- run  `sudo mongo <SHARD_ALIAS>:27018` and `rs.initiate()` in the mongo shell to initiate the replica set

Shard alias: `shard1`, `shard2`, etc.
Shard repl set name: `shardReplSet1`,  `shardReplSet2`, etc.


## 3. Router Server (make sure shard and config servers are set up)

### Create Router Server and Sharding Config

1. Start the mongos daemon (assuming config is running on host `config`): `sudo mongos --configdb configReplSet/config:27019 --bind_ip localhost,router --fork --logpath /var/log/mongodb.log` 
2. Log into mongos: `mongo router:27017`
3. First execute `use cloud` to create database if haven’t created already
4. To add replica shards from step 2 to the cluster, run these commands, one for each replica shard until everything is added.  `sh.addShard("shardReplSet1/shard1:27018")`, `sh.addShard("shardReplSet2/shard2:27018")` ... , `sh.addShard("shardReplSet8/shard8:27018")`
5. Enable sharding on the db `sh.enableSharding("cloud")`
6. Choose `hashed` sharding strategy and collection to shard `sh.shardCollection("cloud.messages", { _id: "hashed" })`

### Data Ingress
1. `git clone https://github.com/andrewwong97/cloud-computing.git`
2. `cd cloud-computing/mapreduce/gen_data`
3. Run `p1.sh`, `p2.sh`, `p3.sh`, `p4.sh` in order or in parallel.


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

## Chained MapReduce
As a simple initial test, we create 2^10 random samples of key, message pairs as would be found in or database, and pipes it to the mapper and reducer: `./test_mapreduce.sh`

In order to trigger the full chained mapreduce test, run the following on the mapreduce node: `./test_chained_mapreduce <db_size> <keyset_size> <num_chains> <redis_size>`. The `db_size` specifies the number of entires in the database - in our case, 8GB was about 58354000 entries. The `keyset_size` specifies the initial set of keys to be computed on. The `num_chains` specifies the number of iterations of consecutive map-reduce stages. The `redis_size` specifies the size in MB for the redis cache.

Each execution will run tests for both the `single` and `cloud` (sharded with or without replicas) databaseses. It flushes the local redis cache and re-initializes with the specified size. Job times for each chain and cahce hit/miss statistics are logged to STDOUT.

On each of the shard servers, run `./mapreduce/db_profile.sh <outfile>`. This will log the CPU and memory usage every 200ms to `outfile` as a CSV. For the case of shards with replicas, the CPU of each process running each replica will be logged, and can be aggregated later for analysis. Between profiling, we must kill all `mongo`, `mongod`, and `mongos` processes in order to have consistent and unbiased metrics.
