#!/bin/bash
mongo << EOF
use single
db.messages.drop()
EOF

for i in $(seq 0 133);
do
   rm data1.json
   python c1.py $i
   mongoimport --db single --collection messages --file data1.json --jsonArray
done