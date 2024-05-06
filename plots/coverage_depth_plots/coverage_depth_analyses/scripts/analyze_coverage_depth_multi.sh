#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-prep          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --output=read_analyses/slurm/mosdepth-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

# convert primer location bed to amplicon location bed
function prepareBedFile() # <scheme> <outfile>
{
    conda activate conda/env-plot
    python read_analyses/scripts/primerToAmpliconBed.py --bounds "outer" $1 > $2
    conda deactivate
}


# set variables
v2a_primers=read_analyses/inputs/V4.1.SARS-CoV-2.primer.bed
amplicon_bed=read_analyses/inputs/V4.1.amplicons.bed
gene_bed=read_analyses/inputs/gene_locations.bed

# # get bed file with amplicon locations
# prepareBedFile $v2a_primers $amplicon_bed

module load samtools

conda activate conda/env-mosdepth
for plate_dir in ont/MixedControl-*-fastqs; do
    sbatch plots/coverage_depth_plots/coverage_depth_analyses/scripts/analyze_coverage_depth.sh $plate_dir
done