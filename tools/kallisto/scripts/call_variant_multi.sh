#!/bin/bash

ref_dir=$1 # directory with sequences for variant calling
single_ref_path=$2 # path to single reference sequence to compare against
mkdir tools/kallisto/slurm

while read lineage lineage_count; do

    echo "Running: tools/kallisto/scripts/call_variant_by_lineage.sh ${ref_dir}/${lineage} ${single_ref_path}"
    sbatch --output=tools/kallisto/slurm/var_call-${lineage}-%j.out tools/kallisto/scripts/call_variant_by_lineage.sh ${ref_dir}/${lineage} ${single_ref_path}

done < ${ref_dir}/lineages.txt
