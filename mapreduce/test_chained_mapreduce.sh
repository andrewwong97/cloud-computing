#!/bin/bash

# $1 - size of database
DB_SIZE=$1

# $2 - starting query set size
KEY_SIZE=$2

# $3 - number of chains
NUM_CHAINS=$3

redis-cli flushall

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

    cp "temp_$COUNTER.txt" "$1_output.txt"
    rm -rf temp_*.txt
}

#echo "Replicated:"
#test "cloud" $NUM_CHAINS

echo "Single:"
test "single" $NUM_CHAINS
redis-cli flushall

