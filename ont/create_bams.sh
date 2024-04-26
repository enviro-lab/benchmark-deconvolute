#!/usr/bin/env bash
set -eu

ref=software/sars-cov-2-reference.fasta

mkdir -p ont/slurm
# create bams for each sample in each plate
for d in ont/MixedControl-*-fastqs; do
    bam_dir=$d/output/alignments
    mkdir -p $bam_dir
    fastq_dir=$d/output/porechop_kraken_trimmed
    for f in $fastq_dir/*.fastq.gz; do
        ### only use one of the below options:
        ## a) for one-at-a-time alignment, uncomment the following line
        #bash ont/align_reads.sh $ref $f $bam_dir

        ## b) for batch submission of alignment step, uncomment the following line
        sbatch --output=ont/slurm/align_reads-%j.out ont/align_reads.sh $ref $f $bam_dir
    done
done