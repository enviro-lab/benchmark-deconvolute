#!/usr/bin/env bash
#SBATCH --time=2-00:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16    # Number of nodes and processors per node requested by job
#SBATCH --mem=100gb           	# Maximum physical memory to use for job
#SBATCH --partition=Nebula       # Job queue to submit this script to
#SBATCH --array=0-5
#SBATCH --output=plots/coverage_depth_heatmaps/slurm/%j_%a.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
module load samtools
set -eu
mkdir -p plots/coverage_depth_heatmaps/slurm

dl[0]='05-05-23-A41'
dl[1]='05-16-23-A41'
dl[2]='06-26-23-A41'
dl[3]='05-05-23-V2'
dl[4]='06-16-23-V2'
dl[5]='07-12-23-V2A'

plate=${dl[$SLURM_ARRAY_TASK_ID]}


bam_dir="ont/MixedControl-${plate}-fastqs/output/alignments"
outdir="ont/MixedControl-${plate}-fastqs/output/coverage_stats"
mkdir -p $outdir

for bam in $bam_dir/*.bam; do
    sample=$(basename $bam | cut -d. -f1 | cut -d_ -f1)
    echo "Getting coverage info for $sample ($bam)"
    samtools coverage $bam > $outdir/${sample}_samtools_coverage.tsv
done