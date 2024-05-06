#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4     # Number of nodes and processors per node requested by job
#SBATCH --mem=60gb           # Maximum physical memory to use for job
module purge
module load anaconda3
conda activate conda/env-kraken2
set -eu

fastq=$1
plate=$2
sample=$3
outdir=ont/MixedControl-${plate}-fastqs/output/kraken/
mkdir -p $outdir
kraken2 \
    --db plots/kraken/db \
    --threads 4 \
    --report ${outdir}/${sample}_k2_report.txt \
    --gzip-compressed \
    $fastq
    ## unwanted options:
    # --report-minimizer-data \
    # --output ${outdir}/${sample}.kraken.out \