import redis
import sys

from pymongo import MongoClient
from util import redis_config

assert(len(sys.argv) == 2)

client = MongoClient('mongodb://{}:27017'.format(sys.argv[1]))
db = client['single']
cache = redis.Redis(host=redis_config['host'], port=redis_config['port'], db=redis_config['db'])


def get(key):
    message = cache.get(key)
    if message:
        return message
    else:
        entry = db.messages.find_one({'_id': key})
        message = entry['message']
        cache.set(key, message)
        return message

for line in sys.stdin:
    key = line.strip()
    val = get(int(key))
    print('{}\t{}'.format(key, val))
