#!/bin/bash
mongo router:27017/single << EOF
use single
db.messages.drop()
EOF

for i in $(seq 134 267);
do
   python create_data.py $i
   mongoimport --db single --collection messages --file data.json --jsonArray
done