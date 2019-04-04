from pymongo import MongoClient
import json


def getDB():
    config = json.loads(open('config.json', 'r').read())
    client = MongoClient(str(config['mongo-dev']))
    return client['cloud']