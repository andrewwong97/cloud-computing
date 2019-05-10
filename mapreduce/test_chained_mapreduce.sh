#!/bin/bash

# $1 - size of database
N=$1

# $2 - starting query set size
M=$2

shuf -i 0-$N -n $M > test_input.txt

# $1 - db type (single, cloud), $2 - number of chains
function test {

	if [ $2 = 1 ]; then
		cat test_input.txt | python db_client.py $1 | python mapper.py | python reducer.py > "$1_$2_output.txt"
	else

		COUNTER=0
		cat test_input.txt | python db_client.py $1 | python mapper.py | python reducer.py > "$COUNTER.txt"
		while [ $((COUNTER + 2)) -lt $2 ]; do
			cat "$COUNTER.txt" | python db_client.py $1 | python mapper.py | python reducer.py > "$((COUNTER+1)).txt"
			rm "$COUNTER.txt"
			let COUNTER=COUNTER+1 
		done

		cat "$COUNTER.txt" | python db_client.py $1 | python mapper.py | python reducer.py > "$1_$2_output.txt"
		rm "$COUNTER.txt"
	fi
}

echo "==================== 1 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated: $DATE"
time (test "cloud" 1)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Single: $DATE"
time (test "single" 1)
echo


echo "==================== 2 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated: $DATE"
time (test "cloud" 2)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Single: $DATE"
time (test "single" 2)
echo


echo "==================== 4 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated: $DATE"
time (test "cloud" 4)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Signle: $DATE"
time (test "single" 4)
echo


echo "==================== 8 Chain ===================="
DATE=`date +"%H:%M:%S:%s%:z"`
echo "Replicated: $DATE"
time (test "cloud" 8)
echo

DATE=`date +"%H:%M:%S:%s%:z"`
echo "Single: $DATE"
time (test "single" 8)
echo