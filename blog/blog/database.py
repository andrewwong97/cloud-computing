from pymongo import MongoClient
import redis
import json


def getDB():
    config = json.loads(open('config.json', 'r').read())
    client = MongoClient(str(config['mongo-dev']))
    return client['cloud']


def getCache():
    config = json.loads(open('config.json', 'r').read())['redis']
    return redis.Redis(host=config['host'], port=config['port'], db=config['db'])
