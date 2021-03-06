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
echo "Test DB (in memory Python dict):"
time (test "test_db.py" 1)
echo

echo "Replicated DB (sharded across nodes):"
time (test "shard_db.py" 1)
echo

echo "Cached DB (single node with Redis)"
time (test "cache_db.py" 1)
echo

echo "==================== 2 Chain ===================="
echo "Test DB (in memory Python dict):"
time (test "test_db.py" 2)
echo

echo "Replicated DB (sharded across nodes):"
time (test "shard_db.py" 2)
echo

echo "Cached DB (single node with Redis)"
time (test "cache_db.py" 2)
echo


echo "==================== 4 Chain ===================="
echo "Test DB (in memory Python dict):"
time (test "test_db.py" 4)
echo

echo "Replicated DB (sharded across nodes):"
time (test "shard_db.py" 4)
echo

echo "Cached DB (single node with Redis)"
time (test "cache_db.py" 4)
echo



echo "==================== 8 Chain ===================="
echo "Test DB (in memory Python dict):"
time (test "test_db.py" 8)
echo

echo "Replicated DB (sharded across nodes):"
time (test "shard_db.py" 8)
echo

echo "Cached DB (single node with Redis)"
time (test "cache_db.py" 8)
echo
