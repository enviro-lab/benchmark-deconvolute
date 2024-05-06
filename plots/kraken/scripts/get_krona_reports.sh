#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4     # Number of nodes and processors per node requested by job
#SBATCH --mem=60gb           # Maximum physical memory to use for job
#SBATCH --output=plots/kraken/slurm/krona-%j.out          # User-defined name for job
module purge
module load anaconda3
set -eu

krona_plots=plots/kraken/krona_plots
mkdir -p $krona_plots

# # get krona reports individually for each sample for each of the three artic plates
# conda activate conda/env-krona
# for plate in 05-05-23-A41 05-16-23-A41 06-26-23-A41; do
#     report_dir=ont/MixedControl-${plate}-fastqs/output/kraken
#     ktImportTaxonomy -t 5 -m 3 -o ${krona_plots}/${plate}-krona.html ${report_dir}/*_k2_report.txt
# done


# ### get krona report for all samples combined into one fastq
# # get kraken 2 combined report for each plate
# conda activate conda/env-kraken2
# for plate in 05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A; do
#     report_dir=ont/MixedControl-${plate}-fastqs/output/kraken
#     fastq_dir=ont/MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed
#     combined_fastq_dir=ont/MixedControl-${plate}-fastqs/output/fastq_combined
#     mkdir -p $combined_fastq_dir
#     combined_fastq=${combined_fastq_dir}/${plate}_combined.fastq.gz

#     # get combined fastq (excluding NFWs)
#     if [ ! -f ${combined_fastq} ]; then
#         echo "combining fastqs for $plate"
#         zcat $fastq_dir/Mixture*fastq.gz | gzip > $combined_fastq
#     fi

#     # run kraken 2, not keeping classified/unclassified output
#     if [ ! -f ${report_dir}/${plate}_combined_k2_report.txt ]; then
#         echo "running kraken 2 on $plate"
#         kraken2 \
#             --db plots/kraken/db \
#             --threads 4 \
#             --report ${report_dir}/${plate}_combined_k2_report.txt \
#             --gzip-compressed \
#             $combined_fastq > /dev/null
#     fi
# done
# conda deactivate

# # get krona report
# echo "creating krona report"
# conda activate conda/env-krona
# ktImportTaxonomy -t 5 -m 3 -o ${krona_plots}/combined-krona-report.html ont/MixedControl-*-fastqs/output/kraken/*_combined_k2_report.txt
# conda deactivate

# create kraken reports with sars-cov-2 dropped
conda activate conda/env-plot
for f in ont/MixedControl-*-fastqs/output/kraken/*_combined_k2_report.txt; do
    echo $f
    plots/kraken/scripts/drop_sars_cov_2.py $f ${f/.txt/-no-sars-cov-2.txt}
    # break
done
conda deactivate

# get sarscov2-free krona report
echo "creating krona report"
conda activate conda/env-krona
ktImportTaxonomy -t 5 -m 3 -o ${krona_plots}/combined-krona-report-no-sars-cov-2.html ont/MixedControl-*-fastqs/output/kraken/*_combined_k2_report-no-sars-cov-2.txt
conda deactivate