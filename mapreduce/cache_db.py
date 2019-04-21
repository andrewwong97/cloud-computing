import redis
import sys

from util import client, redis_config

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
