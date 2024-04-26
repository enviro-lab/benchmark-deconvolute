#!/usr/bin/env bash

# This script is what we used to collect the fastqs from their original, 
#  local locations and make them accessible in this repo.
# Use `populate_ont_reads.sh` instead if beginning from NCBI downloads

ww_plates=/projects/enviro_lab/WW-UNCC
ont=/projects/enviro_lab/decon_compare/benchmark-deconvolute-redo/ont
for d in $ont/MixedControl-*-fastqs; do
    plate=`basename $d`
    echo $plate
    ww_fastqs_dir=$ww_plates/$plate/output/porechop_kraken_trimmed
    linked_fastqs_dir=$ont/$plate/output/porechop_kraken_trimmed
    mkdir -p $linked_fastqs_dir
    ln -s $ww_fastqs_dir/* -t $linked_fastqs_dir/
done