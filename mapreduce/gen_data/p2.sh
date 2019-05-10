#!/bin/bash
for i in $(seq 134 267);
do
   rm data2.json
   python c2.py $i
   mongoimport --db single --collection messages --file data2.json --jsonArray
done