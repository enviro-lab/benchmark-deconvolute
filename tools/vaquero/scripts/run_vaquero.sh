#!/usr/bin/env bash
#SBATCH --time=2-00:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16    # Number of nodes and processors per node requested by job
#SBATCH --mem=100gb           	# Maximum physical memory to use for job
#SBATCH --partition=Nebula       # Job queue to submit this script to
#SBATCH --array=0-5
#SBATCH --output=tools/vaquero/slurm/%j_%a.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu
module load R &>/dev/null || true
export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.1
export R_LIBS=tools/vaquero/rlib
vaquero_sw=$(realpath software/VaQuERo)
scripts="$vaquero_sw/scripts"
resources="$vaquero_sw/resources"
reference=$(realpath software/sars-cov-2-reference.fasta)

dl[0]='05-05-23-A41'
dl[1]='05-16-23-A41'
dl[2]='06-26-23-A41'
dl[3]='05-05-23-V2'
dl[4]='06-16-23-V2'
dl[5]='07-12-23-V2A'

plate=${dl[$SLURM_ARRAY_TASK_ID]}

# derived paths/variables
data_dir=$(realpath ont/MixedControl-${plate}-fastqs/)
fastq_dir=${data_dir}/output/porechop_kraken_trimmed
samples_dir=${data_dir}/output/samples
metadata=${data_dir}/MixedControl-${plate}.csv
outdir=tools/vaquero/MixedControl_output/$plate
vcfs=${outdir}/vcf
mkdir -p $outdir $vcfs
outdir=$(realpath $outdir)

module load anaconda3
conda activate conda/env-vaquero
mutation_data=${outdir}/mutationDataSub.tsv.gz
vaquero_metadata=${outdir}/metadata-${plate}.tsv

# get lowfreq VCFs
echo "Getting lowfreq VCFs"
for bam in ${data_dir}/output/alignments/*.bam; do
    sample=$(basename $bam | cut -d. -f1 | cut -d_ -f1)
    vcf=$vcfs/$sample.vcf.gz
    lofreq call --ref $reference -o $vcf $bam
done

# convert & combine VCFs into single tsv
echo "Combining VCFs into single tsv"
first_vcf=true
for vcf in $vcfs/*.vcf.gz; do
    if [[ $first_vcf = true ]]; then 
        python3 ${scripts}/vcf2tsv_long.py -i ${vcf} -o ${mutation_data}
        first_vcf=false
    else
        python3 ${scripts}/vcf2tsv_long.py -i ${vcf} --append -o ${mutation_data}
    fi
done

# get metadata file
echo "Forging VaQuERo-style metadata"
python tools/vaquero/scripts/write_vaquero_metadata.py --metadata $metadata --output $vaquero_metadata

# Run VaQuERo
echo "Running VaQuERo"
vaquero_log=tools/vaquero/log/vaquero-$plate.log
mkdir -p tools/vaquero/log
mutation_list=$resources/mutations_list_grouped_pango_codonPhased_2023-07-31_Austria.csv
smarker=$resources/mutations_special_2022-12-21.csv
pmarker=$resources/mutations_problematic_vss1_v3.csv
    # --voi='B.1.1.7;B.1.617.2;P.1;B.1.351' (default)

Rscript ${scripts}/VaQuERo_v2.r \
    --dir=${outdir} \
    --country=USA --bbsouth=33.7 --bbnorth=36.7 --bbwest=-84.4 --bbeast=-75.3 \
    --metadata=${vaquero_metadata} \
    --marker="${mutation_list}" \
    --smarker="${smarker}" \
    --pmarker="${pmarker}" \
    --data=${mutation_data} \
    --plottp 1000 \
    --smoothingsample 0 \
    --voi='B.1.617.2;B.1.1.529;BA.1;B.1.526;P.1;B.1.1.7;BA.2;B.2.12.1;BA.5;BA.4' \
    --colorBase='XBB.1;BQ.1;BA.1;BA.2;BA.4;BA.5;B.1.1;B.1.617;B.1.526;B;P.1' | tee $vaquero_log || true

# check that vaquero finished
grep -q '^PROGRESS: plotting overview Sankey plot' $vaquero_log || (echo "VaQuERo failed" && exit 1)

# Convert results to freyja-like aggregated format
agg_dir=tools/vaquero/agg
mkdir -p $agg_dir
agg=${agg_dir}/$plate-aggregated.tsv
vaquero_predictions=${outdir}/globalFittedData.csv
echo "Writing out aggregated results to: $agg"
conda activate conda/env-plot
python tools/vaquero/scripts/aggregate_predictions.py -f $vaquero_predictions -o $agg
echo "Done with $plate"
date