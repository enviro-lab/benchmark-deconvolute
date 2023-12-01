#!/usr/bin/env bash
module load anaconda3
set -eu

conda activate ./conda/env-plot

plates="05-05-23-A41 05-16-23-A41 06-26-23-A41"

for plate in $plates; do

    agg_file=./tools/alcov/MixedControl_output/raw/Alcov_samples_lineages-${plate}.csv
    outfile=./tools/alcov/MixedControl_output/agg/Alcov_samples_lineages-${plate}.tsv

    # convert to freyja abundance tsv
    ./tools/alcov/scripts/aggregate_predictions.py $agg_file -o $outfile

done