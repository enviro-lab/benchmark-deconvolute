#!/usr/bin/env bash
#SBATCH --time=06:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1     # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           # Maximum physical memory to use for job
#SBATCH --job-name=lineagespot          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --mail-user=$USER@uncc.edu        # Job queue to submit this script to
#SBATCH --mail-type=END,FAIL        # Job queue to submit this script to
#SBATCH --array=0-5
module load anaconda3
set -eu

mutfile='lineagespot/mutations.csv'

module load R
export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.1
sw=software
snpEff() { $sw/jdk-20.0.2/bin/java -jar $sw/snpEff/snpEff.jar "${@}"; }

reference='software/sars-cov-2-reference.fasta'

dl[0]='05-05-23-A41'
dl[1]='05-16-23-A41'
dl[2]='06-26-23-A41'
dl[3]='05-05-23-V2'
dl[4]='06-16-23-V2'
dl[5]='07-12-23-V2A'

plate=${dl[$SLURM_ARRAY_TASK_ID]}
echo "Running lineagespot for plate: $plate"

outdir=lineagespot/output/${plate}
decon_dir=${outdir}/deconvolute
vcf_dir=${outdir}/vcfs
mkdir -p $vcf_dir $decon_dir

for old_vcf in ont/MixedControl-${plate}-fastqs/output/samples/*.pass.vcf.gz; do
# for old_vcf in ont/MixedControl-${plate}-fastqs/output/samples/Mixture35.pass.vcf.gz; do
    bam=${old_vcf/pass.vcf.gz/primertrimmed.rg.sorted.bam}
    sample=`basename $old_vcf | cut -d. -f1`
    vcf=$vcf_dir/$sample.vcf
    temp_vcf=${vcf}.tmp
    af_vcf=${vcf/.vcf/.filterless.vcf}
    lineagespot_out=$decon_dir/$sample.csv

    # # skip if done already
    # if [[ -f $lineagespot_out ]]; then continue; fi

    echo "Analyzing $sample"

    # create a vcf from `bam` that has allele frequency included
    conda activate software/C-WAP/conda/env-bcftools
    bcftools mpileup -d3000 -f $reference $bam |  bcftools call -c -v - | grep -v '^##' > $af_vcf

    ####### # # use allele freq to estimate allele depth (AD) values
    ####### # python lineagespot/scripts/get_AD_info.py $af_vcf

    # converting vcfs (to remove duplicates)
    python lineagespot/scripts/get_vcf.py -f $old_vcf -o $temp_vcf -a $af_vcf
    # add annotations
    snpEff ann NC_045512.2 $temp_vcf > $vcf

    # if temp_vcf has no mutations, skip lineagespot
    if [[ -z $(grep -v '#' $temp_vcf) ]]; then
        echo '"lineage","sample","meanAF","meanAF_uniq","minAF_uniq_nonzero","N","lineage N. rules","lineage prop."' > $lineagespot_out
    else # otherwise, run it
        echo "Running lineagespot: $vcf"
        Rscript lineagespot/scripts/run_lineagespot.R $vcf $lineagespot_out
    fi
done

# combine into one file
agg_deconv=$outdir/deconv.csv
xsv cat rows $decon_dir/* > $agg_deconv

# Aggregate to freyja-like tsv
conda activate conda/env-plot
python lineagespot/scripts/aggregate_predictions.py -f ${outdir}/deconv.csv -o ${outdir}/deconvoluted.agg.csv
