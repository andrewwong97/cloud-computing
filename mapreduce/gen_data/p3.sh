#!/bin/bash
for i in $(seq 268 401);
do
   rm data3.json
   python c3.py $i
   mongoimport --port 27018 --db cloud --collection messages --file data3.json --numInsertionWorkers 8 --jsonArray
done