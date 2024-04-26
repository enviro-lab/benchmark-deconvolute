#!/usr/bin/env bash
set -eu

if [[ ! -d conda/env-alcov ]]; then
    echo "make sure you set up the conda env for alcov"
    echo "See conda/README.md"
fi

plates="05-05-23-A41 05-05-23-V2 05-16-23-A41 06-16-23-V2 06-26-23-A41 07-12-23-V2A"
for plate in $plates; do

    # Use one of the following options:

    # # a) for one-at-a-time runs
    # bash tools/alcov/scripts/run_alcov.sh $plate

    # b) for batch submission
    job_name=alcov_${plate}
    mkdir -p tools/alcov/slurm
    sbatch --output=tools/alcov/slurm/alcov-%j.out --job-name=$job_name tools/alcov/scripts/run_alcov.sh $plate

done