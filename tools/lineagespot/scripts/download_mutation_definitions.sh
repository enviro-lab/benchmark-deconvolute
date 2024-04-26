#!/usr/bin/env bash

mutfile='tools/lineagespot/mutations.csv'

module load R
# this is where our install of R is # NOTE: Edit as needed
# source R_LIBS_USER from config file
source tools/lineagespot/scripts/config.txt
# export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.1

# echo "Getting variant details..."
# # variants='B.1.1.7' # not really used, right now...
# # Rscript tools/lineagespot/scripts/download_variant_info.R ${mutfile} ${variants}
# Rscript tools/lineagespot/scripts/download_variant_info.R ${mutfile}

module purge
module load anaconda3
conda activate conda/env-plot
echo "Converting mutations to reference files..."
ref_dir=${R_LIBS_USER}/lineagespot/extdata/ref
python tools/lineagespot/scripts/mutation2ref.py -f $mutfile -r $ref_dir -m 0.8

