#!/usr/bin/env bash

# MixedControl-05-05-23-A41 (Controls only - Artic)
# MixedControl-05-05-23-V2 (Controls only - Varskip)
# MixedControl-05-16-23-A41 (Controls with Neg spike in - Artic)
# MixedControl-06-16-23-V2 (Controls with Neg spike in - Varskip)
# MixedControl-06-26-23-A41 (Control with Pos spike in - Artic)
# MixedControl-07-12-23-V2A (Control with Pos spike in - Varskip)

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in ${plates}; do
    fastq_dir=ont/MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed
    outdir=tools/kallisto/scripts/MixedControl_output/${plate}
    slurmdir=${outdir}/slurm
    mkdir -p ${slurmdir}
    
    # set kallisto running for each plate
    sbatch --output="${slurmdir}/%j.out" tools/kallisto/scripts/analyze_plate.sh $fastq_dir $outdir
    # tools/kallisto/scripts/analyze_plate.sh $fastq_dir $outdir
done