#!/bin/bash
#SBATCH -c 20
#SBATCH -t 10:00:00
#SBATCH -p Orion
#SBATCH --mem=10G

set -eu

lineage=${1}
single_ref_path=$2 # path to single reference sequence to compare against

for fasta in ${lineage}/*.fa; do 
    # align and sort
    minimap2 -c -x asm20 --end-bonus 100 -t 20 --cs $single_ref_path $fasta 2>${fasta%.fa}.paftools.log | sort -k6,6 -k8,8n > ${fasta%.fa}.paf && paftools.js call -s ${fasta%.fa} -L 100 -f $single_ref_path ${fasta%.fa}.paf > ${fasta%.fa}.vcf 2>>${fasta%.fa}.paftools.log;
    bgzip -f ${fasta%.fa}.vcf;
    bcftools index -f ${fasta%.fa}.vcf.gz;
done;

sample_count=$(ls ${lineage}/*.vcf.gz | wc -l);
if [[ ${sample_count} -eq 1 ]]; then 
    cp ${lineage}/*.vcf.gz ${lineage}_merged.vcf.gz;
else 
    bcftools merge -o ${lineage}_merged.vcf.gz -O z -0 ${lineage}/*.vcf.gz;
fi;
vcftools --gzvcf ${lineage}_merged.vcf.gz --out ${lineage}_merged --site-pi;
vcftools --gzvcf ${lineage}_merged.vcf.gz --out ${lineage}_merged --freq;