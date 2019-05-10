#!/bin/bash
for i in $(seq 402 536);
do
   rm data4.json
   python c4.py $i
   mongoimport --db single --collection messages --file data4.json --jsonArray
done