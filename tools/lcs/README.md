# Deconvolution with LCS

## Documentation/Links
[GitHub](https://github.com/rvalieris/LCS)

## Software installation
```bash
cd software
git clone https://github.com/rvalieris/LCS.git
cd LCS
conda env create -p software/conda/env-lcs -f conda.env.yaml
conda activate software/conda/env-lcs
pip install grpcio==1.57.0
# pip install opencensus
# pip install prometheus-client
# pip install aiohttp
# pip install aiohttp_cors
# pip install pydantic
```

## Some adjustments (some , if specified; others automatically part of [tools/lcs/scripts/run_lcs.sh](./scripts/run_lcs.sh))
### (manual) Fix some segmentation fault issues (because the UCSC dataset is huge)
In 'rules/ucsc-matrix-pipe.py', edit `rule sample_list` so `rows = rows.sample(n=10000)`.

### Marker source table:
* We chose to use the USHER-based dataset

### [Config](software/LCS/rules/config.py) adjustments:
1. Add/select correct primer scheme file as fasta.
   * `tools/lcs/run_lsc.sh` does this automatically
2. (manual) Select a recent date for PB_VERSION in the config

### Other pre-lcs preparation
Use `/projects/enviro_lab/lcs/scripts/link_samples.sh <fastq_dir>` to
1. Put sample fastqs in 'software/LCS/data/fastq'
2. Create tags file listing sample names

## How to actually run LCS
If only running one plate, these first two steps can be ignored, as (1) was already done when creating the lcs conda env, and (2) is unnecessary. If doing more plates, we have examples in [tools/lcs/scripts](tools/lcs/scripts) for a second and third plate
1. For more plates, create a new script for each lcs run and a copy of the LCS github repo in which each plate is analyzed. To create this copy and remove files that would hinder future runs, you'll need to do something like:
```bash
cp software/LCS software/LCS2
# If you've already run a plate in software/LCS, remove the following files. Otherwise, the below commands should be unnecessary.
rm -rf software/LCS2/.snakemake
rm -rf software/LCS2/outputs/pool_map
rm -rf software/LCS2/outputs/pool_mutect
rm -rf software/LCS2/outputs/pool_mutect_unused
rm -rf software/LCS2/outputs/decompose
rm software/LCS2/outputs/variants_table/pool_samples_${plate}.tsv
``` 

2. Make a new copy of the main executable script and edit the variables `plate` and `lcs_sw_dir`:
```bash
cp tools/lcs/run_lcs.sh tools/lcs/run_lcs_2.sh
# manually edit `plate`
# manually edit `lcs_sw_dir`
```
