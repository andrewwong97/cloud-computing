#!/bin/bash
for i in $(seq 268 401);
do
   rm data3.json
   python create_data.py $i
   mongoimport --db single --collection messages --file data3.json --jsonArray
done