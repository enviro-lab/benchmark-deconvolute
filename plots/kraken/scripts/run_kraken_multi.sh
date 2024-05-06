#!/usr/bin/env bash
mkdir -p plots/kraken/slurm

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"
for plate in $plates; do
    for fastq in ont/MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed/*fastq.gz; do
        sample=$(basename $fastq .fastq.gz | cut -d_ -f1)
        job_name=kraken_${plate}_${sample}
        sbatch --output=plots/kraken/slurm/$job_name.out --job-name=$job_name plots/kraken/scripts/run_kraken.sh $fastq $plate $sample
    done
done