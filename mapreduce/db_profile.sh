#!/bin/bash
# $1 - output csv file 
rm -rf $1
> $1
echo "TIME_STAMP, CPU (%), MEM (kB)" | tee -a $1

while :
do
	DATE=`date +"%H:%M:%S:%s%:z"`
	CPU=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 10)
	MEM=$(sudo pmap -x $(pgrep mongo) | tail -1 | grep -o -E '[0-9]+' | head -1)
	echo "$DATE, $CPU, $MEM" | tee -a $1	
done
