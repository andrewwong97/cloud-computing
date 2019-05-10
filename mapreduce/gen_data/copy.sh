for i in $(seq 0 2);
do
	x = $i * 500000
	y = x + 500000
	mongo --eval "db.messages.find({_id: {$gte: x, $lt: y}}).forEach(function(doc){db.temp.insert(doc);});"
	mongoexport --host single --port 27017 --db single --collection temp --out data.json
	mongoimport --host router --port 27018 --db test --collection messages --file data.json --jsonArray 
done