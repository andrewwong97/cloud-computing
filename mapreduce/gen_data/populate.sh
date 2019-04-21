#!/bin/bash
for i in {0..4}
do
   python create_data.py i
   mongoimport --db test --collection messages --file data.json --jsonArray
done