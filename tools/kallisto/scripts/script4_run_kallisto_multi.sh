#!/usr/bin/env bash
set -eu

agg_dir=tools/kallisto/agg
mkdir -p ${agg_dir}

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in ${plates}; do
    fastq_dir=ont/MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed
    outdir=tools/kallisto/MixedControl_output/${plate}
    slurmdir=${outdir}/slurm
    mkdir -p ${slurmdir}
    
    # set kallisto running for each plate
    sbatch --output="${slurmdir}/%j.out" tools/kallisto/scripts/analyze_plate.sh $fastq_dir $outdir $agg_dir $plate
    # bash tools/kallisto/scripts/analyze_plate.sh $fastq_dir $outdir $agg_dir $plate
done
