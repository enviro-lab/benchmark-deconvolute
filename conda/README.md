# Conda environments used in these scripts
Below is the necessary code for creating each conda environment used in these scripts

## Environments reused in multiple locations
All commands below assume you are starting in the root of the repo.
```bash
cd benchmark-deconvolute
```

### env-plot
This is the main conda env used for plotting and summarizing each tool's lineage abundance outputs in a consistent way based on freyja's format and lineage summarization functions.
```bash
mamba create -y -p conda/env-plot -c conda-forge -c bioconda python=3.10 freyja
conda activate conda/env-plot
pip install freyja-plot
# if using jupyter notebooks
mamba install -y ipykernal
# for stats:
mamba install -y -c researchpy researchpy
conda deactivate
```

### env-kallisto-variants
```bash
mamba create -y -p conda/env-kallisto-variants -c bioconda -c defaults pyvcf vcftools bcftools minimap2 kallisto py-bgzip
```

### env-preprocess
```bash
mamba create -y -p conda/env-preprocess -c bioconda pyvcf
conda activate conda/env-preprocess
conda install python=3.7 # this upgrades pyvcf to python3.7 and avoids a datetime bug
pip install pandas
```

### env-lcs
```bash
cd software
git clone https://github.com/rvalieris/LCS.git
cd LCS
mamba env create -y -p conda/env-lcs -f conda.env.yaml
conda activate conda/env-lcs
pip install grpcio==1.57.0
# # the below may be required, but I'm not sure
# pip install opencensus
# pip install prometheus-client
# pip install aiohttp
# pip install aiohttp_cors
# pip install pydantic
cd -
```

### env-alcov
```bash
mamba create -y -p conda/env-alcov python=3.10
conda activate conda/env-alcov
pip install alcov #ortools
mamba install ortools-python
conda deactivate
```

### env-lollipop
```bash
mamba create -y -p conda/env-lollipop lollipop smallgenomeutilities cojac
conda activate conda/env-lollipop
# install biopython==1.81 since lollipop uses GFFParser which uses the depricated 'strand' attribute in Biopython's SeqFeature
pip install biopython==1.81
conda deactivate
## NOTE: we should not need this but there's an issue where we have duplicate reads in the bam file after minimap2 ... | samtools sort
# edit one script to deal with files with missing reads
sed -i "s/alignment += read.query_sequence\[idx:idx + length]/if not read.query_sequence:\n                    # deal with missing reads\n                    alignment += ''.join(np.repeat('-', length))\n                else:\n                    alignment += read.query_sequence\[idx:idx + length]/" conda/env-lollipop/lib/python3.10/site-packages/smallgenomeutilities/__pileup__.py
```

### env-mosdepth
```bash
mamba create -y -p conda/env-mosdepth -c bioconda mosdepth
```

### env-freebayes
```bash
mamba create -y -p conda/env-freebayes -c bioconda freebayes
```

### env-vaquero
```bash
mamba create -y -p conda/env-vaquero -c bioconda pysam lofreq pandas python=3.10
```

### env-kallisto-variants
```
mamba create -p conda/env-kallisto-variants -c bioconda -c defaults pyvcf vcftools bcftools minimap2 kallisto py-bgzip
```

### env-preprocess
```
mamba create -p conda/env-preprocess -c bioconda pyvcf
conda install python=3.7 # this upgrades pyvcf to python3.7 and avoids a datetime bug
pip install pandas
```

### env-krona
```bash
mamba create -y -p conda/env-krona -c bioconda krona
conda activate conda/env-krona
ktUpdateTaxonomy.sh
conda deactivate
```