#!/bin/bash
for i in $(seq 268 401);
do
   python create_data.py $i
   mongoimport --db single --collection messages --file data.json --jsonArray
done