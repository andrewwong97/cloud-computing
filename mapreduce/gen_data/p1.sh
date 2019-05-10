#!/bin/bash
mongo router:27017/single << EOF
use single
db.messages.drop()
EOF

for i in $(seq 0 133);
do
   python create_data.py $i
   mongoimport --db single --collection messages --file data.json --jsonArray
done