#!/usr/bin/env bash
module purge
module load anaconda3
conda activate conda/env-plot/

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in $plates; do
    echo "Preparing results for $plate"
    tsv_dir=kallisto-cwap/tsvs/${plate}
    agg_dir=kallisto-cwap/agg
    mkdir -p "${tsv_dir}" "${agg_dir}"
    cwap_dir=ont/MixedControl-${plate}-fastqs/output/C-WAP/cwapResults

    # gather cwap kraken/bracken results
    echo "Copying necessary files"
    cp $cwap_dir/*/*kallisto.out "${tsv_dir}"

    # aggregate results
    echo "Aggregating results"
    python kallisto-cwap/scripts/aggregate_predictions.py --tsv "${tsv_dir}" -o "${agg_dir}/$plate.tsv"

done