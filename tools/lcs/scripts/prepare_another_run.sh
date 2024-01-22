#!/usr/bin/env bash
#SBATCH --time=01:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6    # Number of nodes and processors per node requested by job
#SBATCH --partition=Draco       # Job queue to submit this script to

## SCRIPT PURPOSE:
# copies important files over from existing download without having to clone the LCS git repo
# removes files that need to be produced anew, if they exist

n=6

echo "Copying over useful files"
cp -r software/LCS software/LCS$n
echo "Removing excess files"
rm -rf software/LCS$n/.snakemake &
rm -rf software/LCS$n/outputs/pool_map &
rm -rf software/LCS$n/outputs/pool_mutect &
rm -rf software/LCS$n/outputs/pool_mutect_unused &
rm -rf software/LCS$n/outputs/decompose &
rm software/LCS$n/outputs/variants_table/pool_samples_${plate}.tsv