#!/bin/bash
for i in $(seq 268 401);
do
   rm data3.json
   python c3.py $i
   mongoimport --db single --collection messages --file data3.json --jsonArray
done