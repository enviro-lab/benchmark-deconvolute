# ONT Directoy

This is where we stored our trimmed/filtered fastqs, bam files, and any other plate/sample-specific files used by the various deconvolution tools.

## General directory structure
We used one outer directory referred to in these scripts as "ont" which contains directories for each plate. The first plate is expanded to show the contents. The output directory comes from running our [covid-analysis pipeline](https://github.com/enviro-lab/covid-analysis).

```
ont
├── MixedControl-05-05-23-A41-fastqs
│   ├── fastq_pass                      # contains our original, unfiltered reads
│   ├── output
│   │   ├── C-WAP                       # contains output of C-WAP
│   │   ├── porechop_kraken_trimmed     # contains filtered/trimmed reads for each sample
│   │   └── samples                     # contains bam file for each sample (`artic minion` output)
├── MixedControl-05-16-23-A41-fastqs
├── MixedControl-06-26-23-A41-fastqs
├── MixedControl-05-05-23-V2-fastqs
├── MixedControl-06-16-23-V2-fastqs
└── MixedControl-07-12-23-V2A-fastqs
```

## How to fill in this directory with the relevant data
Using NCBI's sra-tools, you can use `fastq-dump` to collect all the filtered reads related to the NCBI BioProject [PRJNA1031245](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1031245). These are the reads found in `ont/MixedControl-$plate-fastqs/porechop_kraken_trimmed` after running [covid-analysis](https://github.com/enviro-lab/covid-analysis). The simplest way to get everything in the correct place would be to do the following:

1. Place the relevant reads in individual barcode directories like `ont/MixedControl-$plate-fastqs/output/porechop_kraken_trimmed/mixtureXX.fastq.gz`.
   * Make sure both sra-tools and entrez-direct are installed and on your path (perhaps in a conda env).
    ```bash
    mamba create -p conda/env-ncbi-tools -c bioconda sra-tools entrez-direct
    conda activate conda/env-ncbi-tools
    ```
   * Then run one of the following:
    ```bash
    # run this line to download fastqs from sra
    bash ont/populate_ont_reads.sh

    # (enviro-lab testing only) run this line to link fastqs from thier local directoies on ou cluster
    bash ont/populate_ont_read_from_local.sh
    ```

2. Create sorted, indexed bam files for each sample based on the filtered reads. These will be stored in `ont/MixedControl-$plate-fastqs/output/alignments` in bam format.
   * Make sure both samtools and minimap2 are installed and on your path (perhaps in a conda env).
    ```bash
    mamba create -p conda/env-align -c bioconda samtools minimap2
    conda activate conda/env-align
    ```
   * Then run the following:
    ```bash
    bash ont/create_bams.sh
    ```
