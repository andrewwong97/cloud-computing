import random
import hashlib
import string
import json
import sys
import os
from pymongo import MongoClient
import time

t = time.time()
client = MongoClient('mongodb://router:27018')
db = client['cloud']

min_lc = ord(b'0')
len_lc = 74

def write_random_lowercase(n):
    ba = bytearray(os.urandom(n))
    for i, b in enumerate(ba):
        ba[i] = min_lc + b % len_lc # convert 0..255 to 97..122
    return ba.decode('utf-8')

d = []
print(sys.argv[1])
init = int(sys.argv[1]) * 500000

for i in range(init, init + 500000):
	d.append({ "_id": i, "message": write_random_lowercase(100) })

result = db.messages.insert_many(d)

print('inserted: {}'.format(len(result.inserted_ids)))

print('time: {}'.format(time.time()-t))

# with open('data4.json', 'w') as f:
# 	json.dump(d, f, indent=4, ensure_ascii=False)