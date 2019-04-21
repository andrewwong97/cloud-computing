from pymongo import MongoClient

client = MongoClient('mongodb://router:27017')

redis_config = { "host": "localhost", "port": 6379, "db": 0}

# number of database entries
N = 50000