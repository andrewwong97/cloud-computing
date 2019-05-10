#!/bin/bash
for i in $(seq 134 267);
do
   rm data2.json
   python c2.py $i
   mongoimport --port 27018 --db cloud --collection messages --file data2.json --numInsertionWorkers 8 --jsonArray
done