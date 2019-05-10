#!/bin/bash
for i in $(seq 402 536);
do
   rm data1.json
   python c1.py $i
   mongoimport --port 27018 --db cloud --collection messages --file data1.json --jsonArray
done