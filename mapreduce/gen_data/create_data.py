import random
import hashlib
import string
import json

from util import N

# generate random mongodb key (_id field) and message
# export mongodb dump to stdout
# can be directly imported using mongoimport tool
# by running mongoimport --db cloud --collection messages --file /path/to/data.json --jsonArray
d = []
for i in range(sys.argv[1]*500000, sys.argv[1] + 500000):
	message = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(100))
	d.append({ "_id": i, "message": message })
with open('data.json', 'w') as f:
	json.dump(d, f, indent=4, ensure_ascii=False)
