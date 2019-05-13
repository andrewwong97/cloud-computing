import numpy as np
import matplotlib.pyplot as plt

DB_SIZE = 32
REPLICAS_PER_SHARD = 1
SHARDS = 1

COLORS = [
    'xkcd:red',
    'xkcd:purple',
    'xkcd:blue',
    'xkcd:black',
    'xkcd:green',
    'xkcd:orange',
    'xkcd:pink',
    'xkcd:brown'
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
        if sample.db_size == 32:
            samples.append(sample)

dependent_vars = [
    (lambda x: x.job_t, 'Job Time (ns)'),
    (lambda x: x.cpu_avg, 'Avg % CPU Usage'),
    (lambda x: x.cpu_max, 'Max % CPU Usage'),
    (lambda x: x.mem_avg, 'Avg Memory (GB)'),
    (lambda x: x.mem_max, 'Max Memory (GB)')
]

legend_labels = []
colors = list(map(lambda x: color(x), range(0, len(samples))))
labels = list(map(lambda x: x.cache, samples))

fig, sp = plt.subplots(len(dependent_vars), sharex=True)
fig.suptitle('Results vs. MR Length ({} Replica/Shard, {} Shard)'.format(REPLICAS_PER_SHARD, SHARDS), fontsize=14, fontweight='bold')
fig.subplots_adjust(top=0.92)

for plt_index, (dependent_var, ylabel) in enumerate(dependent_vars):
    for i in range(0, int(len(samples)/8)):
        x = list(map(lambda x: x.chain, samples[i*8:(i+1)*8]))
        y = list(map(dependent_var, samples[i*8:(i+1)*8]))
        if plt_index > 2:
            y = np.divide(y, 10**6)

        sp[plt_index].scatter(x, y, c=COLORS[i], label=str(samples[i*8].cache) + ' GB Cache', alpha=1)
        sp[plt_index].plot(x, y, c=COLORS[i])

    sp[plt_index].set(ylabel=ylabel)

sp[-1].legend(bbox_to_anchor=(0., -0.52, 1., .102), loc='upper left',
           ncol=3, mode="expand", borderaxespad=0.)
sp[-1].set(xlabel='MR Chain Length')
plt.show()
