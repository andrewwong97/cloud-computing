#!/bin/bash
# $1 - output csv file 
CSV_OUTPUT=$1

# resart mongod to track accurate memory usage
sudo pkill mongod
sleep 2
sudo mongod --bind_ip localhost,single --dbpath /data/db --fork --logpath /var/log/mongodb.log
sleep 2

rm -rf $CSV_OUTPUT
> $CSV_OUTPUT
echo "TIME_STAMP, CPU (%), MEM (kB)" | tee -a $CSV_OUTPUT

while :
do
	DATE=`date +"%H:%M:%S:%N"`

    # top CPU output is inconsistent, hacky fix
	CPU=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 9)
    if [[ $CPU != *"."* ]]; then
        CPU=$(top -b -n 1| grep -w mongod | tr -s ' ' | cut -d ' ' -f 10)
    fi
	MEM=$(sudo pmap -x $(pgrep mongo) | tail -1 | grep -o -E '[0-9]+' | head -1)
	echo "$DATE, $CPU, $MEM" | tee -a $CSV_OUTPUT	
done
