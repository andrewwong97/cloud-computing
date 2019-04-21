import sys

from util import client

db = client['cloud']

def get(key):
    entry = db.messages.find_one({'_id': key})
    message = entry['message']
    return message

for line in sys.stdin:
    key = line.strip()
    val = get(int(key))
    print('{}\t{}'.format(key, val))
