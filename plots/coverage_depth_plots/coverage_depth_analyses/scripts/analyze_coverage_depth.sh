#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-prep          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --output=plots/coverage_depth_plots/coverage_depth_analyses/slurm/mosdepth-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

# set variables
v2a_primers=plots/coverage_depth_plots/coverage_depth_analyses/inputs/V4.1.SARS-CoV-2.primer.bed
amplicon_bed=plots/coverage_depth_plots/coverage_depth_analyses/inputs/V4.1.amplicons.bed
gene_bed=plots/coverage_depth_plots/coverage_depth_analyses/inputs/gene_locations.bed

module load samtools

conda activate conda/env-mosdepth

plate_dir="$1"
# echo $plate_dir

# get plate name
plate=$(basename $plate_dir)
plate=${plate/MixedControl-/}
plate=${plate/-fastqs/}
echo $plate

# set/create paths
alignment_dir=$(realpath ${plate_dir}/output/alignments)
echo $alignment_dir
threshold_depth=$(realpath ${plate_dir}/output/mosdepth-threshold)
amplicon_depth=$(realpath ${plate_dir}/output/mosdepth-amplicons)
gene_depth=$(realpath ${plate_dir}/output/mosdepth-genes)
read_counts=$(realpath ${plate_dir}/output/read_counts.tsv)
mkdir -p ${threshold_depth} ${amplicon_depth} ${gene_depth}
first_loop=true

for bam in ${alignment_dir}/*bam; do

    # get sample name
    sample=$(basename $bam .bam | cut -d_ -f1)
    echo "$plate: $sample"

    # get number of bases in each threshold level
    mosdepth --fast-mode --no-per-base --threads 4 --by ${gene_bed} --thresholds 0,1,10,30,100,500,1000,5000,10000 ${threshold_depth}/${sample} ${bam}

    # # get depth by amplicon
    # mosdepth --fast-mode --no-per-base --threads 4 --by ${amplicon_bed} ${amplicon_depth}/${sample} ${bam}

    # # get depth by gene
    # mosdepth --fast-mode --no-per-base --threads 4 --by ${gene_bed} ${gene_depth}/${sample} ${bam}

    # # start read count file
    # if $first_loop; then
    #     echo -e "sample\tread_counts\tplate" > ${read_counts}
    #     first_loop=false
    # fi
    # # get read counts
    # echo -e "${sample}\t$(samtools view -c -F 0x900 ${bam})\t${plate}" >> ${read_counts}

done
