#!/bin/bash
for i in $(seq 268 401);
do
   rm data3.json
   python c1.py $i
   mongoimport --port 27018 --db cloud --collection messages --file data3.json --jsonArray
done