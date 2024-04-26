#!/usr/bin/env bash
#SBATCH --time=06:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1     # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           # Maximum physical memory to use for job
#SBATCH --job-name=lineagespot-sample          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --output=tools/lineagespot/slurm/indiv-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

module load R
export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.1
sw=software
markDuplicates() { $sw/jdk/bin/java -jar $sw/picard.jar MarkDuplicates "${@}"; }
snpEff() { $sw/jdk/bin/java -jar $sw/snpEff/snpEff.jar "${@}"; }


# prepare vcfs for individual sample and run lineagespot

# bring in sample-specific variables/paths
bam="${1}"
marked_duplicates="${2}"
freebayes_vcf_dir="${3}"
vcf_dir="${4}"
decon_dir="${5}"
plate="${6}"
reference="${7}"

# get derived variables/paths
sample=`basename $bam | cut -d. -f1 | cut -d_ -f1`
# echo "$plate: $sample"
md_bam=${marked_duplicates}/${sample}.bam
md_dups=${marked_duplicates}/${sample}_dup_metrics.txt
freebayes_vcf=${freebayes_vcf_dir}/${sample}.vcf
vcf=$vcf_dir/${sample}.vcf
lineagespot_out=${decon_dir}/${sample}.csv

# # Filter out duplicates from bam
# echo "Marking duplicates: ${bam}"
# markDuplicates I=${bam} O=${md_bam} M=${md_dups}
# # NOTE: this step seems to fail at locating optical duplicates, but we'll continue anyway. See message below:
# ## WARNING	2024-04-18 16:47:00	AbstractOpticalDuplicateFinderCommandLineProgram	Default READ_NAME_REGEX '<optimized capture of last three ':' separated fields as numeric values>' did not match read name '94e36868-6e32-43b7-8713-3e8d5d98e0ba'.  You may need to specify a READ_NAME_REGEX in order to correctly identify optical duplicates.

# # produce vcf
# echo "Creating freebayes vcf: ${freebayes_vcf}"
# conda activate /projects/enviro_lab/decon_compare/benchmark-deconvolute-redo/conda/env-freebayes
# freebayes \
#     -f ${reference} \
#     -F 0.01 \
#     -C 1 \
#     --pooled-continuous ${md_bam} > ${freebayes_vcf}
# # edit freebayes_vcf to have genome name in the format expected by snpEff
# sed -i 's/MN908947.3/NC_045512.2/g' ${freebayes_vcf}

# # add annotations
# echo "Annotating: ${vcf}"
# rm ${vcf} # TEMP
# snpEff ann NC_045512.2 ${freebayes_vcf} > ${vcf}

# if freebayes_vcf has no mutations, skip lineagespot
if [[ -z $(grep -v '#' ${freebayes_vcf}) ]]; then
    echo '"lineage","sample","meanAF","meanAF_uniq","minAF_uniq_nonzero","N","lineage N. rules","lineage prop."' > ${lineagespot_out}
else # otherwise, run it
    echo "Running lineagespot: ${vcf}"
    Rscript tools/lineagespot/scripts/run_lineagespot.R ${vcf} ${lineagespot_out}
fi
