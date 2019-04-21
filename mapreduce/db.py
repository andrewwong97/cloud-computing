import json
import pickle
import sys

from util import N

data_json = 'data.json'
cached_db = 'data.pkl'

def load_db():
	try:
		with open(cached_db, 'rb') as file:
			return pickle.load(file)
	except:
		with open(data_json) as file:
			data = json.load(file)
		print(len(data))

		db = {}
		for entry in data:
			key, val = entry['_id']['$oid'], entry['message']
			if int(key, 16) % N in db:
				print('collision')

			db[int(key, 16) % N] = (key, val)

		with open(cached_db, 'wb') as file:
			pickle.dump(db, file)

		return db

db = load_db()
# print(len(db))
# print(list(sorted(db.keys())))

for line in sys.stdin:
    key = int(line.strip())
    key, val = db[key]
    print('{}\t{}'.format(key, val))