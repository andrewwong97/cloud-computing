import random
import hashlib
import string
from bson.objectid import ObjectId
import json

# generate random mongodb key (_id field) and message
# export mongodb dump to stdout
# can be directly imported using mongoimport tool
# by running mongoimport --db cloud --collection messages --file /path/to/data.json --jsonArray
d = []
for i in range(5000):
	key = str(ObjectId())
	message = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(100))
	d.append({ "_id": { "$oid": key }, "message": message })
with open('data.json', 'w') as f:
	f.write(json.dumps(d))
