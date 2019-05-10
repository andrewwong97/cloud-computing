import random
import hashlib
import string
import json
import sys

# generate random mongodb key (_id field) and message
# export mongodb dump to stdout
# can be directly imported using mongoimport tool
# by running mongoimport --db cloud --collection messages --file /path/to/data.json --jsonArray
d = []
print(sys.argv[1])
init = int(sys.argv[1])*500000
#file = 'data' + sys.argv[1] + '.json'

choice = string.ascii_uppercase + string.ascii_lowercase + string.digits

for i in range(init, init + 500000):
	message = ''.join(random.choice(choice) for _ in range(100))
	d.append({ "_id": i, "message": message })



with open('data4.json', 'w') as f:
	json.dump(d, f, indent=4, ensure_ascii=False)