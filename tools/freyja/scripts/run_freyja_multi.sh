#!/usr/bin/env bash
#SBATCH --time=04:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6    # Number of nodes and processors per node requested by job
#SBATCH --mem=2gb           	# Maximum physical memory to use for job
#SBATCH --job-name=freyja_runs
#SBATCH --output=ont/slurm/freyja_runs-%j.out
date
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

ref=software/sars-cov-2-reference.fasta
agg_dir="tools/freyja/agg"
mkdir -p ${agg_dir}

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in $plates; do

    (
    outdir="tools/freyja/MixedControl_output/MixedControl-${plate}-fastqs"
    bam_dir=ont/MixedControl-${plate}-fastqs/output/alignments
    demixed=${outdir}/demixed
    mkdir -p ${demixed}

    # run freyja for each plate
    for bam in ${bam_dir}/*.bam; do
        sample=$(basename ${bam} .bam | cut -d'_' -f1)

        echo "${plate}: running freyja for ${sample}..."

        ## only use one of the below options:

        # # a) for one-at-a-time
        # bash tools/freyja/scripts/run_freyja.sh $ref $bam $outdir $sample

        # b) for batch submission
        job_name=freyja_${plate}_${sample}
        mkdir -p tools/freyja/slurm
        sbatch --output=tools/freyja/slurm/freyja-%j.out --job-name=$job_name tools/freyja/scripts/run_freyja.sh $ref $bam $outdir $sample
    done

    # wait for all freyja jobs to finish (in case of batch submission)
    # note, this could wait forever if freyja jobs fail to produce demix output
    while true; do
        if [[ $(ls $bam_dir/*.bam | wc -l) -eq $(ls $demixed | wc -l) ]]; then break; else sleep 5; fi
    done
    sleep 5

    # this env should have freyja and freyja-plot installed
    conda activate conda/env-plot

    # aggregate demix files...
    agg_file="${agg_dir}/freyja-aggregated-${plate}.tsv"
    echo "${plate}: aggregating files from $demixed to $agg_file..."
    freyja aggregate $demixed/ --output ${agg_file}
    ) &

done

wait
printf "Freyja runs complete -"
date