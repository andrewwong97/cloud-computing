#!/bin/bash
# $1 - output csv file, $2 - wait between samples (in ms) 
rm -rf $1
> $1
echo "TIME_STAMP, CPU, MEMORY, TOTAL" | tee -a $1

while :
do
	DATE=`date +"%H:%M:%S:%s%:z"`

	# cpu usage
	echo -n "$DATE, " | tee -a $1
	CPU=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 10)
	echo -n "$CPU, " | tee -a $1
	
	# memory usage (percentage)
	MONGOD_MEM=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 11)
	TOTAL_MEM=$(free -m | grep Mem | tr -s ' ' | cut -d ' ' -f 2)
	echo -n "$MONGOD_MEM, " | tee -a $1
	echo "$TOTAL_MEM" | tee -a $1
	
	sleep $2
done
