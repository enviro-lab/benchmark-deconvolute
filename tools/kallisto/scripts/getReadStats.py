#!/usr/bin/env python
#SBATCH --time=10:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32    # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           	# Maximum physical memory to use for job
#SBATCH --partition=Orion       # Job queue to submit this script to

import gzip
import sys
from pathlib import Path

lengths = []
count = 0

if "-h" in sys.argv:
    print(f"""Usage:
           # Unzips and reads listed fastq.gz files
             {sys.argv[0]} FILE(S)
             or
           # Reads fastq as text from stdin
             zcat *.fastq.gz | sys.argv[0]""")

if len(sys.argv) > 1 and Path(sys.argv[1]).exists():
    for file in sys.argv[1:]:
        print(file)
        with gzip.open(file) as fh:
            for line in fh:
                if count % 4 == 1:
                    lengths.append(len(line)-1)
                count += 1
else:
    for line in sys.stdin:
        if count % 4 == 1:
            lengths.append(len(line)-1)
        count += 1
# stats
from statistics import mean, stdev
mean_read_length = mean(lengths)
print("Mean:",mean_read_length)

std_deviation = stdev(lengths)
print("Standard Deviation:",std_deviation)