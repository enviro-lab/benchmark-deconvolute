#!/usr/bin/env bash
#SBATCH --time=2-00:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24    # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           	# Maximum physical memory to use for job
#SBATCH --partition=Andromeda       # Job queue to submit this script to
#SBATCH --output=/projects/enviro_lab/decon_compare/kallisto/build_reference_set/slurm/%j.out
set -eu

# cd tools/kallisto/build_reference_set

# meta=tools/kallisto/gisaid_data/metadata_tsv_2023_07_15.tar.xz
meta=tools/kallisto/gisaid_data/metadata.usa.tsv
ref=software/sars-cov-2-reference.fasta
fasta=tools/kallisto/gisaid_data/gisaid.fasta
vocs='B.1.1.7,B.1.351,B.1.427,B.1.429,B.1.526,P.1'
reference_set=tools/kallisto/reference_set


##################################################################################
## NOTE:
## The first few steps prepare for a general analysis and should already be done.
##################################################################################

conda activate conda/env-kallisto-variants

# Step 4:
echo "CMD: tools/kallisto/scripts/call_variant_multi.sh ${reference_set} ${ref}"
tools/kallisto/scripts/call_variant_multi.sh ${reference_set} ${ref}

# Step 5:
echo "CMD: python tools/kallisto/wastewater_analysis/pipeline/select_samples.py -m ${meta} -f ${fasta} -o ${reference_set} --vcf ${reference_set}/*_merged.vcf.gz --freq ${reference_set}/*_merged.frq"
python tools/kallisto/wastewater_analysis/pipeline/select_samples.py -m ${meta} -f ${fasta} -o ${reference_set} --vcf ${reference_set}/*_merged.vcf.gz --freq ${reference_set}/*_merged.frq

# Step 6:
echo "CMD: kallisto index -i ${reference_set}/sequences.kallisto_idx ${reference_set}/sequences.fasta"
kallisto index -i ${reference_set}/sequences.kallisto_idx ${reference_set}/sequences.fasta