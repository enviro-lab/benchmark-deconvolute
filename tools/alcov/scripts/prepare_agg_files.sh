#!/usr/bin/env bash
module load anaconda3
set -eu

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in $plates; do

    samples_file=tools/alcov/samples_list/${plate}.txt
    alcov_tmp_out=tools/alcov/samples_list/${plate}_lineages.csv
    alcov_csv=tools/alcov/MixedControl_output/raw/Alcov_samples_lineages-${plate}.csv
    outfile=tools/alcov/MixedControl_output/agg/Alcov_samples_lineages-${plate}.tsv

    # prep for alcov
    mkdir -p tools/alcov/samples_list
    for bam in ont/MixedControl-${plate}-fastqs/output/samples/*.bam; do
        sample=$(basename $bam | cut -d. -f1)
        echo -e "${bam}\t${sample}"
    done > $samples_file

    # run alcov
    conda activate conda/env-alcov
    alcov find_lineages $samples_file
    mv $alcov_tmp_out $alcov_csv

    # convert to freyja abundance tsv
    conda activate conda/env-plot
    python tools/alcov/scripts/aggregate_predictions.py $alcov_csv -o $outfile

done