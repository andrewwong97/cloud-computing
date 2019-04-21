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
init = int(sys.argv[1])
file = 'data' + sys.argv[1] + '.json'

for i in range(init*500000, init+ 500000):
	message = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(100))
	d.append({ "_id": i, "message": message })
with open(file, 'w') as f:
	json.dump(d, f, indent=4, ensure_ascii=False)

close(file)
