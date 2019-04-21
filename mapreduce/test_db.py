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

        db = {}
        for entry in data:
            key, val = entry['_id'], entry['message']
            db[key] = val

        with open(cached_db, 'wb') as file:
            pickle.dump(db, file)

        return db

db = load_db()

def get(key):
    return db[key]

for line in sys.stdin:
    key = line.strip()
    val = get(int(key))
    print('{}\t{}'.format(key, val))