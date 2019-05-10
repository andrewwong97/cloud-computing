#!/bin/bash
mongos router:27018 << EOF
use cloud
db.dropDatabase()
EOF

for i in $(seq 0 133);
do
   rm data1.json
   python c1.py $i
   mongoimport --port 27018 --db cloud --collection messages --file data1.json --numInsertionWorkers 8 --jsonArray
done