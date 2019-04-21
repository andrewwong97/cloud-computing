#!/bin/bash

# size of database
N=50000

# starting query set size
M=10

shuf -i 0-$N -n $M > test_input.txt

function test {
	cat test_input.txt | python $1 | python mapper.py | python reducer.py > test_output_1.txt
	cat test_output_1.txt | python $1 | python mapper.py | python reducer.py > test_output_2.txt
	cat test_output_2.txt | python $1 | python mapper.py | python reducer.py > test_output_3.txt
	cat test_output_3.txt | python $1 | python mapper.py | python reducer.py > test_output_4.txt
	cat test_output_4.txt | python $1 | python mapper.py | python reducer.py > test_output.txt

	rm test_output_1.txt
	rm test_output_2.txt
	rm test_output_3.txt
	rm test_output_4.txt

	cp test_output.txt "$1_output.txt"
	rm test_output.txt
}

echo "Test DB (in memory Python dict):"
time (test "test_db.py")
echo

echo "Replicated DB (sharded across nodes):"
time (test "shard_db.py")
echo

echo "Cached DB (single node with Redis)"
time (test "cache_db.py")
echo
