import random
import hashlib
import string
import json
import sys
import os

min_lc = ord(b'a')
len_lc = 26

def write_random_lowercase(n):
    ba = bytearray(os.urandom(n))
    for i, b in enumerate(ba):
        ba[i] = min_lc + b % len_lc # convert 0..255 to 97..122
    return ba.decode('utf-8')

# generate random mongodb key (_id field) and message
# export mongodb dump to stdout
# can be directly imported using mongoimport tool
# by running mongoimport --db cloud --collection messages --file /path/to/data.json --jsonArray
d = []
print(sys.argv[1])
init = int(sys.argv[1]) * 500000

for i in range(init, init + 500000):
	d.append({ "_id": i, "message": write_random_lowercase(100) })

with open('data2.json', 'w') as f:
	json.dump(d, f, indent=4, ensure_ascii=False)