#!/bin/bash
for i in $(seq 402 536);
do
   python create_data.py $i
   mongoimport --db single --collection messages --file data.json --jsonArray
done