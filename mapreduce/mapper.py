import sys
import hashlib

from util import N

for line in sys.stdin:
    line = line.strip()
    key, message = line.split()
    mod_hash  = int(hashlib.sha256(message.encode()).hexdigest(), 16) % N
    print("{}\t{}".format(key, str(mod_hash)))