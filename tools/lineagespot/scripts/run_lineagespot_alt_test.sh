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

module load R
export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.1
sw=software
markDuplicates() { $sw/jdk/bin/java -jar $sw/picard.jar MarkDuplicates "${@}"; }
snpEff() { $sw/jdk/bin/java -jar $sw/snpEff/snpEff.jar "${@}"; }

reference='software/sars-cov-2-reference.fasta'

dl[0]='05-05-23-A41'
dl[1]='05-16-23-A41'
dl[2]='06-26-23-A41'
dl[3]='05-05-23-V2'
dl[4]='06-16-23-V2'
dl[5]='07-12-23-V2A'

plate=${dl[$SLURM_ARRAY_TASK_ID]}
echo "Running lineagespot (alt_test) for plate: $plate"

data_dir=$(realpath ont/MixedControl-${plate}-fastqs/output/)
outdir="$(realpath tools/lineagespot)/MixedControl_output_alt/${plate}"
marked_duplicates=${outdir}/marked_duplicates
freebayes_vcf_dir=${outdir}/freebayes_vcfs
vcf_dir=${outdir}/vcfs
decon_dir=${outdir}/deconvolute
mkdir -p $outdir $marked_duplicates $freebayes_vcf_dir $vcf_dir $decon_dir

for bam in ${data_dir}/alignments-with-supplemental/*.bam; do
    sample=`basename $bam | cut -d. -f1 | cut -d_ -f1`
    echo "$plate: $sample"
    md_bam=${marked_duplicates}/${sample}.bam
    md_dups=${marked_duplicates}/${sample}_dup_metrics.txt
    freebayes_vcf=${freebayes_vcf_dir}/${sample}.vcf
    vcf=$vcf_dir/${sample}.vcf
    lineagespot_out=$decon_dir/$sample.csv

    # Filter out duplicates from bam
    echo "Marking duplicates: $bam"
    markDuplicates I=${bam} O=${md_bam} M=${md_dups}
    # NOTE: this step seems to fail at locating optical duplicates, but we'll continue anyway. See message below:
    ## WARNING	2024-04-18 16:47:00	AbstractOpticalDuplicateFinderCommandLineProgram	Default READ_NAME_REGEX '<optimized capture of last three ':' separated fields as numeric values>' did not match read name '94e36868-6e32-43b7-8713-3e8d5d98e0ba'.  You may need to specify a READ_NAME_REGEX in order to correctly identify optical duplicates.

    # produce vcf
    echo "Creating freebayes vcf: $freebayes_vcf"
    conda activate /projects/enviro_lab/decon_compare/benchmark-deconvolute-redo/conda/env-freebayes
    freebayes \
        -f ${reference} \
        -F 0.01 \
        -C 1 \
        --pooled-continuous ${md_bam} > ${freebayes_vcf}

    # add annotations
    echo "Annotating: $vcf"
    snpEff ann NC_045512.2 $freebayes_vcf > $vcf

    # if freebayes_vcf has no mutations, skip lineagespot
    if [[ -z $(grep -v '#' $freebayes_vcf) ]]; then
        echo '"lineage","sample","meanAF","meanAF_uniq","minAF_uniq_nonzero","N","lineage N. rules","lineage prop."' > $lineagespot_out
    else # otherwise, run it
        echo "Running lineagespot: $vcf"
        Rscript tools/lineagespot/scripts/run_lineagespot.R $vcf $lineagespot_out
    fi


    ### OLD CODE BELOW ### (Don't use anymore)
    # temp_vcf=${vcf}.tmp
    # af_vcf=${vcf/.vcf/.filterless.vcf}

    # # skip if done already
    # if [[ -f $lineagespot_out ]]; then continue; fi

    # echo "Analyzing $sample"

    # # create a vcf from `bam` that has allele frequency included
    # conda activate software/C-WAP/conda/env-bcftools
    # bcftools mpileup -d3000 -f $reference $bam |  bcftools call -c -v - | grep -v '^##' > $af_vcf

    # ####### # # use allele freq to estimate allele depth (AD) values
    # ####### # python lineagespot/scripts/get_AD_info.py $af_vcf

    # # converting vcfs (to remove duplicates)
    # python lineagespot/scripts/get_vcf.py -f $old_vcf -o $temp_vcf -a $af_vcf

done

# combine into one file
agg_deconv=$outdir/deconv.csv
xsv cat rows $decon_dir/* > $agg_deconv

# Aggregate to freyja-like tsv
conda activate conda/env-plot
python tools/lineagespot/scripts/aggregate_predictions.py -f ${outdir}/deconv.csv -o ${outdir}/deconvoluted.agg.csv
