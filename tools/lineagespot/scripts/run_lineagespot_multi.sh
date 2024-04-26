#!/usr/bin/env bash
#SBATCH --time=06:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1     # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           # Maximum physical memory to use for job
#SBATCH --job-name=lineagespot          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --array=0-5
#SBATCH --output=tools/lineagespot/slurm/%j-%a.out
module purge &>/dev/null
#SBATCH --array=0
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

reference='software/sars-cov-2-reference.fasta'

dl[0]='05-05-23-A41'
dl[1]='05-16-23-A41'
dl[2]='06-26-23-A41'
dl[3]='05-05-23-V2'
dl[4]='06-16-23-V2'
dl[5]='07-12-23-V2A'

# # test # TEMP
# SLURM_ARRAY_TASK_ID=0

plate=${dl[$SLURM_ARRAY_TASK_ID]}
echo "Running lineagespot for plate: $plate"

data_dir=$(realpath ont/MixedControl-${plate}-fastqs/output/)
outdir="$(realpath tools/lineagespot)/MixedControl_output/${plate}"
marked_duplicates=${outdir}/marked_duplicates
freebayes_vcf_dir=${outdir}/freebayes_vcfs
vcf_dir=${outdir}/vcfs
decon_dir=${outdir}/deconvolute
mkdir -p $outdir $marked_duplicates $freebayes_vcf_dir $vcf_dir $decon_dir

# for bam in ${data_dir}/alignments/*.bam; do
#     sbatch --job-name="ls-${plate}" tools/lineagespot/scripts/run_lineagespot_sample.sh $bam $marked_duplicates $freebayes_vcf_dir $vcf_dir $decon_dir $plate $reference
# done

# wait for all lineagespot jobs to finish (in case of batch submission)
while true; do
    sleep 5
    if [[  $(squeue --format='%.30j %.8u' -u $USER 2&>/dev/null | grep -c "ls-${plate}") -eq 0 ]]; then break; else sleep 5; fi
    # if [[ $(ls $vcf_dir/* | wc -l) -eq $(ls ${data_dir}/alignments/*.bam | wc -l) || $(squeue --format='%.30j %.8u' -u $USER 2&>/dev/null | grep -c ls-${plate}) -eq 0 ]]; then break; else sleep 5; fi
done
sleep 5


# combine into one file
agg_deconv=$outdir/deconv.csv
xsv cat rows $decon_dir/* | grep -v ',NA,0,0,NA,0,1,0' > $agg_deconv

# Aggregate to freyja-like tsv
conda activate conda/env-plot
agg_dir=tools/lineagespot/agg
mkdir -p $agg_dir
python tools/lineagespot/scripts/aggregate_predictions.py -f ${agg_deconv} -o ${agg_dir}/lineagespot-${plate}.tsv
