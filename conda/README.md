# Conda environments used in these scripts
Below is the necessary code for creating each conda environment used in these scripts

## Environments reused in multiple locations

### env-plot
This is the main conda env used for plotting and summarizing each tool's lineage abundance outputs in a consistent way based on freyja's format and lineage summarization functions.
```bash
conda create -p ./conda/env-plot -c bioconda python=3.10 pandas freyja
conda activate ./conda/env-plot
pip install freyja-plot
conda deactivate
```

### env-kallisto-variants
```bash
mamba create -p ./conda/env-kallisto-variants -c bioconda -c defaults pyvcf vcftools bcftools minimap2 kallisto py-bgzip
```
### env-preprocess
```bash
mamba create -p ./conda/env-preprocess -c bioconda pyvcf
conda activate ./conda/env-preprocess
conda install python=3.7 # this upgrades pyvcf to python3.7 and avoids a datetime bug
pip install pandas
```

### env-lcs
```bash
cd software
git clone https://github.com/rvalieris/LCS.git
cd LCS
conda env create -p software/conda/env-lcs -f conda.env.yaml
conda activate software/conda/env-lcs
pip install grpcio==1.57.0
# # the below may be required, but I'm not sure
# pip install opencensus
# pip install prometheus-client
# pip install aiohttp
# pip install aiohttp_cors
# pip install pydantic
```