#!/usr/bin/env bash
#SBATCH --time=04:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8    # Number of nodes and processors per node requested by job
#SBATCH --mem=4gb           	# Maximum physical memory to use for job

module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

ref=${1}
fastq=${2}
bam_dir=${3}

conda activate conda/env-align

name=$(basename $fastq .fastq.gz)
echo "Creating $bam_dir/$name.bam"
minimap2 -ax map-ont -t 3 $ref $fastq -2 --sam-hit-only \
    | samtools view -@ 8 -b -F 4 -F 256 -F 272 -F 2048 - \
    | samtools sort -@ 8 -o $bam_dir/$name.bam
samtools index $bam_dir/$name.bam

# # Note: this line was used for alignments-with-supplmental instead of the line above (and didn't filter out supplemental reads)
#     | samtools view -@ 8 -b -F 4 -F 256 -F 272 - \