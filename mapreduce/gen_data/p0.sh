#!/bin/bash
for i in $(seq 0 536);
do
   rm data1.json
   python c1.py $i
   mongoimport --port 27018 --db single --collection messages --file data.json --numInsertionWorkers 8 --jsonArray
done