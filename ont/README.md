# ONT Directoy

This is where we stored our trimmed/filtered fastqs, bam files, and any other plate/sample-specific files used by the various deconvolution tools.

## General directoy structure
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

1. Place the relevant reads in individual barcode directories like `ont/MixedControl-$plate-fastqs/fastq_pass/barcodeXX/mixtureXX.fastq.gz`.
   * NOTE: make sure both sra-tools and entrez-direct are installed and on your path (perhaps in a conda env). Then run the following:
    ```bash
    bash ont/populate_ont_reads.sh
    ```

2. Install the [covid-analysis](https://github.com/enviro-lab/covid-analysis) pipeline (& prepare the necessary environments).
    ```bash
    # install via
    git clone git@github.com:enviro-lab/covid-analysis.git software/covid-analysis
    # install necessary conda environments
    bash software/covid-analysis/prepare_envs.sh
    ```

3. Run the covid-analysis pipeline for each plate.
    ```bash
    plates='05-05-23-A41 05-16-23-A41 06-26-23-A41 05-05-23-V2 06-16-23-V2 07-12-23-V2A'
    for plate in $plates; do
    bash ont/MixedControl-$plate-fastqs/run_covid_analysis.sh
    done
    ```

4. If you want the C-WAP output, follow the instructions in the [C-WAP repo](https://github.com/CFSAN-Biostatistics/C-WAP), ensure that sra-tools, kraken2, and nextflow are installed/available, and run the following:
    ```bash
    plates='05-05-23-A41 05-16-23-A41 06-26-23-A41 05-05-23-V2 06-16-23-V2 07-12-23-V2A'
    for plate in $plates; do
        OUTDIR=ont/MixedControl-$plate-fastqs/output/C-WAP
        FASTQS=ont/MixedControl-$plate-fastqs/fastq_pass
        # primer scheme is wither artic v4 or varskip v2a depending on plate suffix (A4a or V2/V2a, respectively)
        PRIMER_SCHEME=/path/to/primer.scheme.bed
        nextflow-21.12.1-edge-all run startWorkflow.nf --platform n --primers "${PRIMER_SCHEME}" --in "${FASTQS}" --out "${OUTDIR}"
        mv "${OUTDIR}/analysisResults" "${OUTDIR}/cwapResults"
    done
    ```