#!/usr/bin/env bash
module purge
module load anaconda3
set -eu
conda activate /projects/enviro_lab/software/conda/env-lineagespot
mutfile='/projects/enviro_lab/decon_compare/lineagespot/mutations.csv'
gff='/projects/enviro_lab/decon_compare/lineagespot/NC_045512.2_annot.gff3'


# echo "Gettinfg gff3"
# wget -O $gff "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=<NC_045512.2>"

echo "Running lineagespot..."
lineagespot -h