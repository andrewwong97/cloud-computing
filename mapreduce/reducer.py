import sys

from util import N

# TODO: use bitvector as wrapper for integer
seen = [False] * N

for line in sys.stdin:

    line = line.strip()
    _, hash_mod = line.split()
    hash_mod = int(hash_mod)

    if not seen[hash_mod]:
        print(hash_mod)
        seen[hash_mod] = True