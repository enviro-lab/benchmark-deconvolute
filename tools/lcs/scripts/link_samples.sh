#!/usr/bin/env bash
## This script takes all *.fastq* files in `fastq_dir` and 
## 1. creates softlinks for them in `outdir`, overwriting any that exist already
## 2. adds their name to the `tags` file

fastq_dir=$1
data_dir=$2
plate=$3
outdir=$data_dir/fastq
tags=$data_dir/tags_pool_$plate

if [[ -d "$outdir" ]]; then rm -rf "$outdir"; fi
mkdir -p "$outdir"
printf '' > "$tags"

for f in "${fastq_dir}"/*; do
    sample_name=`basename "$f" | cut -d_ -f1`
    # echo "sample_name: $sample_name"
    ln -s "$f" "$outdir/$sample_name.fastq.gz"
    echo "$sample_name" >> "$tags"
done