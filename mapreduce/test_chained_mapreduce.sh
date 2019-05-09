#!/bin/bash

# size of database
N=50000

# starting query set size
M=100

shuf -i 0-$N -n $M > test_input.txt

# $1 - db type (test, replicated, cached), $2 - number of chains
function test {

	if [ $2 = 1 ]; then
		cat test_input.txt | python $1 | python mapper.py | python reducer.py > "$1_$2_output.txt"
	else

		COUNTER=0
		cat test_input.txt | python $1 | python mapper.py | python reducer.py > "$COUNTER.txt"
		while [ $((COUNTER + 2)) -lt $2 ]; do
			cat "$COUNTER.txt" | python $1 | python mapper.py | python reducer.py > "$((COUNTER+1)).txt"
			rm "$COUNTER.txt"
			let COUNTER=COUNTER+1 
		done

		cat "$COUNTER.txt" | python $1 | python mapper.py | python reducer.py > "$1_$2_output.txt"
		rm "$COUNTER.txt"
	fi
}

echo "==================== 1 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Test DB (in memory Python dict): $DATE"
time (test "test_db.py" 1)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated DB (sharded across nodes): $DATE"
time (test "shard_db.py" 1)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Cached DB (single node with Redis): $DATE"
time (test "cache_db.py" 1)
echo

echo "==================== 2 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Test DB (in memory Python dict): $DATE"
time (test "test_db.py" 2)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated DB (sharded across nodes): $DATE"
time (test "shard_db.py" 2)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Cached DB (single node with Redis): $DATE"
time (test "cache_db.py" 2)
echo


echo "==================== 4 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Test DB (in memory Python dict): $DATE"
time (test "test_db.py" 4)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated DB (sharded across nodes): $DATE"
time (test "shard_db.py" 4)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Cached DB (single node with Redis): $DATE"
time (test "cache_db.py" 4)
echo



echo "==================== 8 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Test DB (in memory Python dict): $DATE"
time (test "test_db.py" 8)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated DB (sharded across nodes): $DATE"
time (test "shard_db.py" 8)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Cached DB (single node with Redis): $DATE"
time (test "cache_db.py" 8)
echo