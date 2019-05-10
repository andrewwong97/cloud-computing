#!/bin/bash

# $1 - size of database
DB_SIZE=$1

# $2 - starting query set size
KEY_SIZE=$2

# $3 - number of chains
NUM_CHAINS=$3

# $4 - cache size, in number of MB
CACHE_SIZE=$4

# remove old cache size and set new size
sudo sed -i '$ d' /etc/redis/redis.conf
printf "maxmemory %smb" $CACHE_SIZE | sudo tee -a /etc/redis/redis.conf > /dev/null

# reset the cache and restart service
function reset_redis {
    redis-cli flushall > /dev/null
    sudo systemctl stop redis-server.service
    sudo systemctl start redis-server.service
    redis-cli flushall > /dev/null
}

# generate random starting keys
shuf -i 0-$DB_SIZE -n $KEY_SIZE > test_input.txt

# $1 - db type (single, cloud), $2 - number of chains
function test {

    INPUT_FILE=test_input.txt
    COUNTER=0
    while [ $COUNTER -lt $2 ]; do
	DATE=`date +"%H:%M:%S:%N"`
       
	START=$(date +%s%N)
        cat $INPUT_FILE | python db_client.py $1 | python mapper.py | python reducer.py > "temp_$((COUNTER+1)).txt"
        END=$(date +%s%N)
        
        echo "$DATE, $COUNTER, $((END - START))"
        
        INPUT_FILE="temp_$((COUNTER+1)).txt"
        let COUNTER=COUNTER+1 
    done

    # get cache hit/miss statistics
    redis-cli info stats

    cp "temp_$COUNTER.txt" "$1_output.txt"
    rm -rf temp_*.txt
}

# reset_redis
#echo "Replicated:"
#test "cloud" $NUM_CHAINS

reset_redis
echo "Single:"
test "single" $NUM_CHAINS
