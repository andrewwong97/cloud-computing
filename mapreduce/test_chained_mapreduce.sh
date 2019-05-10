#!/bin/bash

# $1 - size of database
DB_SIZE=$1

# $2 - starting query set size
KEY_SIZE=$2

# $3 - number of chains
NUM_CHAINS=$3

shuf -i 0-$DB_SIZE -n $KEY_SIZE > test_input.txt

# $1 - db type (single, cloud), $2 - number of chains
function test {

    INPUT_FILE=test_input.txt
    COUNTER=0
    while [ $COUNTER -lt $2 ]; do
        START=$(($(date +%s%N)/1000000))
        cat $INPUT_FILE | python db_client.py $1 | python mapper.py | python reducer.py > "temp_$((COUNTER+1)).txt")
        END=$(($(date +%s%N)/1000000))
        
        echo "$COUNTER, $((END - START))"
        
        INPUT_FILE="temp_$((COUNTER+1)).txt"
        let COUNTER=COUNTER+1 
    done

    cp "temp_$COUNTER.txt" "$1_output.txt"
    rm -rf temp_*.txt
}

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated: $DATE"
test "cloud" $NUM_CHAINS

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Single: $DATE"
test "single" $NUM_CHAINS