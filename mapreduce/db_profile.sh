#!/bin/bash
# $1 - output csv file 
rm -rf $1
> $1
echo "TIME_STAMP, CPU" | tee -a $1

while :
do
	DATE=`date +"%H:%M:%S:%s%:z"`

	# cpu usage
	echo -n "$DATE, " | tee -a $1
	CPU=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 10)
	echo -n "$CPU" | tee -a $1	
done
