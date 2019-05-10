#!/bin/bash
for i in $(seq 134 267);
do
   python create_data.py $i
   mongoimport --db single --collection messages --file data.json --jsonArray
done