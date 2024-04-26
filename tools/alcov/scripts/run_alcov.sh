#!/usr/bin/env bash
#SBATCH --time=04:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6    # Number of nodes and processors per node requested by job
#SBATCH --mem=2gb           	# Maximum physical memory to use for job
#SBATCH --job-name=freyja_runs
#SBATCH --output=ont/slurm/alcov_runs-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

plate="${1}"


samples_file=tools/alcov/samples_list/${plate}.txt
alcov_tmp_out=tools/alcov/samples_list/${plate}_lineages.csv
alcov_csv=tools/alcov/MixedControl_output/raw/Alcov_samples_lineages-${plate}.csv

agg_dir=tools/alcov/agg
mkdir -p $agg_dir
outfile=${agg_dir}/alcov-${plate}.tsv

# prep for alcov
mkdir -p tools/alcov/samples_list
for bam in ont/MixedControl-${plate}-fastqs/output/alignments/*.bam; do
    sample=$(basename $bam | cut -d. -f1)
    echo -e "${bam}\t${sample}"
done > $samples_file

# run alcov
conda activate conda/env-alcov
alcov find_lineages --save_img=True --csv=True $samples_file
mv $alcov_tmp_out $alcov_csv
conda deactivate

# convert to freyja abundance tsv
conda activate conda/env-plot
python tools/alcov/scripts/aggregate_predictions.py $alcov_csv -o $outfile