#!/usr/bin/env bash

plate=$1
lcs_dir=$2

## Files to move before running a different plate:
# outputs/pool_map
# outputs/pool_mutect
# outputs/pool_mutect_unused
# outputs/decompose
# outputs/variants_table/pool_samples_${plate}.tsv

outdir=${lcs_dir}/outputs
newdir=${lcs_dir}/outputs/${plate}
mkdir -p $newdir

mv ${outdir}/{pool_{map,mutect{,_unused}},decompose,variants_table/pool_samples_${plate}.tsv} $newdir