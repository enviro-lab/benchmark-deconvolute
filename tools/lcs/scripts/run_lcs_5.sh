#!/usr/bin/env bash
#SBATCH --time=2-00:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16    # Number of nodes and processors per node requested by job
#SBATCH --partition=Draco       # Job queue to submit this script to
#SBATCH --mem=192gb           	# Maximum physical memory to use for job
module load anaconda3
#SBATCH --mem=2000gb           	# Maximum physical memory to use for job
set -eu
#SBATCH --mem=1500gb           	# Maximum physical memory to use for job
#SBATCH --gres=gpu:1


### NOTES FOR RERUNNING WITH OTHER PLATES:
## Files to move first:
# outputs/pool_map
# outputs/pool_mutect
# outputs/pool_mutect_unused
# outputs/decompose
# outputs/variants_table/pool_samples_${plate}.tsv

plate='06-16-23-V2'
lcs_sw_dir=software/LCS5

data_dir=${lcs_sw_dir}/data
config=${lcs_sw_dir}/rules/config.py
scheme=vss2a
scheme_file=software/primer_schemes/NEB_VarSkip/V2a/NEB_VarSkip.scheme.bed
reference=software/sars-cov-2-reference.fasta
primer_fasta="${data_dir}/${scheme}_primers.fa"

# # prepare desired primer scheme as fasta and add to config
# ( module load bedtools2
# bedtools getfasta -name -fi $reference -bed $scheme_file | sed '/>/{n;s/^/^/}' > $primer_fasta )
# current_line="$(grep PRIMERS_FA ${config})"
# updated_line="PRIMERS_FA='data/${scheme}_primers.fa'"
# sed -i "s,$current_line,$updated_line,g" $config

echo "Running LCS: $plate..."

fastq_dir=ont/MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed
temp_outdir=${lcs_sw_dir}/outputs/decompose
outdir=lcs/MixedControl_output/$plate
mkdir -p $outdir

# link samples and list in tags file
echo "Creating links to files"
lcs/scripts/link_samples.sh $fastq_dir $data_dir $plate

# run lcs snakemake script
echo "Running lcs snakemake"
conda activate conda/env-lcs
cd $lcs_sw_dir
# snakemake --config markers=pango dataset=${plate}  --cores 16 --resources mem_gb=96
snakemake --config markers=ucsc dataset=${plate}  --cores 16 --resources mem_gb=192 # --rerun-incomplete  # --unlock 
# snakemake --config markers=ucsc dataset=${plate}  --cores 16 --resources mem_gb=192 # --rerun-incomplete 
# --unlock

# mv results (once complete) to useful location
mv ${temp_outdir}/* ${outdir}
lcs/scripts/move_out_old_run.sh ${plate} ${lcs_sw_dir}

# convert results to freyja-like aggregated format
conda activate conda/env-plot
tools/lcs/scripts/aggregate_predictions.py -f ${outdir}/$plate.out -o ${outdir}/$plate-aggregated.tsv