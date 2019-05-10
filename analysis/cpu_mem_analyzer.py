import numpy as np

class Sample:
    def __init__(self, line):
        time, cpu, mem = line.split('\t', 3)
        self.time = time
        self.cpu = float(cpu)
        self.mem = int(mem)

sequences = []
start_new = True
potential_break = False
with open('data.tsv', 'r') as f:
    for line in f:
        sample = Sample(line)
        if sample.cpu == 0:
            if potential_break:
                start_new = True
                potential_break = False
            else:
                potential_break = True
        else:
            if start_new:
                sequences.append([])
                start_new = False
            sequences[-1].append(sample)
            potential_break = False

filtered_sequences = filter(lambda x: len(x) > 2, sequences)

for index, sequence in enumerate(filtered_sequences):
    cpu_percentages = list(map(lambda x: x.cpu, sequence))
    cpu_avg = np.round(np.average(cpu_percentages), decimals=3)
    cpu_max = np.max(cpu_percentages)

    mem_usage = list(map(lambda x: x.mem, sequence))
    mem_avg = np.round(np.average(mem_usage))
    mem_max = np.max(mem_usage)

    print('\t'.join(map(lambda x: str(x), [cpu_avg, cpu_max, mem_avg, mem_max])))
