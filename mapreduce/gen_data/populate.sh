#!/bin/bash
mongo router:27017/test << EOF
use test
db.messages.drop()
EOF

for i in {0..1}
do
   python create_data.py $i
   mongoimport --db test --collection messages --file data.json --jsonArray
done