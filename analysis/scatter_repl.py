from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt

DB_SIZE = 8

COLORS = [
    'xkcd:red',
    'xkcd:purple',
    'xkcd:blue',
    'xkcd:black',
    'xkcd:green',
    'xkcd:orange',
    'xkcd:pink',
    'xkcd:brown',
    'xkcd:magenta',
    'xkcd:yellow',
    'xkcd:teal',
]

def color(index):
    color_index = int(index/8)
    return COLORS[color_index]

class Sample:
    def __init__(self, line):
        db_size, rps, shards, cache, chain, job_t, cpu_avg, cpu_max, mem_avg, mem_max = line.split('\t', 10)
        self.db_size = int(db_size)
        self.rps = int(rps)
        self.shards = int(shards)
        self.cache = int(cache)
        self.chain = int(chain)
        self.job_t = int(job_t)
        self.cpu_avg = float(cpu_avg)
        self.cpu_max = float(cpu_max)
        self.mem_avg = int(mem_avg)
        self.mem_max = int(mem_max)


samples = []
with open('plot.tsv', 'r') as f:
    for line in f:
        sample = Sample(line)
        if db_size == 8:
            samples.append(sample)

dependent_vars = [
    (lambda x: x.job_t, np.sum, 'Job Time (ns)'),
    (lambda x: x.cpu_avg, np.average, 'Avg % CPU Usage'),
    (lambda x: x.cpu_max, np.average, 'Max % CPU Usage'),
    (lambda x: x.mem_avg, lambda x: np.divide(np.average(x), 10**6), 'Total Memory (GB)'),
    (lambda x: x.mem_max, lambda x: np.divide(np.average(x), 10**6), 'Total Memory (GB)')
]

labels = list(map(lambda x: x.cache, samples))

fig, sp = plt.subplots(len(dependent_vars), sharex=True)
fig.suptitle('Results vs. Replicas (1 GB Cache)', fontsize=14, fontweight='bold')
fig.subplots_adjust(top=0.92)

for plt_index, (dependent_var, operator, ylabel) in enumerate(dependent_vars):
    shard_data = defaultdict(list)

    for i in range(0, int(len(samples)/8)):
        if samples[i*8].cache != 1:
            continue

        x = samples[i*8].rps
        y = operator(list(map(dependent_var, samples[i*8:(i+1)*8])))
        shard = samples[i*8].shards
        shard_data[shard].append((x, y))

    for shard, points in sorted(shard_data.items()):
        x = list(map(lambda x: x[0], points))
        y = list(map(lambda x: x[1], points))
        sp[plt_index].scatter(x, y, label=str(shard) + (' Shards' if shard != 1 else ' Shard'), alpha=1)

    sp[plt_index].set(ylabel=ylabel)

sp[-1].legend(bbox_to_anchor=(0., -0.5, 1., .102), loc='upper left',
           ncol=3, mode="expand", borderaxespad=0.)
sp[-1].set(xlabel='Replicas')
sp[-1].set_xticks([1, 2])
plt.show()
