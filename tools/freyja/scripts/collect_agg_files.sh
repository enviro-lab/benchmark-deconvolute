#!/usr/bin/env bash

# this env should have freyja installed
conda activate conda/env-plot

outdir='tools/freyja/MixedControl_output'

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"

for plate in $plates; do

    # edit path so it finds the C-WAP results
    cwap_dir="ont/MixedControl-${plate}-fastqs/output/C-WAP"

    if [[ ! -d $cwap_dir ]]; then echo dir not found: $cwap_dir; continue; else echo "cwap_dir: $cwap_dir"; fi
    agg_file="${outdir}/agg/freyja-aggregated-${plate}.tsv"
    echo $agg_file

    # combine freyja info (from C-WAP) for plate into single directory
    demixed=${outdir}/demixed/demixed_${plate}
    mkdir -p $demixed
    for demix_file in ${cwap_dir}/cwapResults/*/*_freyja.demix; do
    sample=$(basename $(dirname $demix_file))
    sed "s/freyja.variants.tsv/${sample}/g" $demix_file | sed "s/FATAL ERROR/${sample}/g" | sed "s/INSUFFICIENT DATA/${sample}/g" > $demixed/${sample}_freyja.demix
    done

    # aggregate all demix files...
    echo aggregating files from $demixed ...
    freyja aggregate $demixed/ --output ${agg_file}
done