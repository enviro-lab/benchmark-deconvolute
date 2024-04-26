# benchmark-deconvolute
Benchmark Dataset for Evaluation & Comparison Of Nifty, Versatile, & Objective Lineage-Unscrambling-Tool Execution

## About
This repo is designed to house repeatable explanations for the processes we used to compare SARS-CoV-2 lineage deconvolution tools on a standard dataset for our preprint [A gold standard dataset for lineage abundance estimation from wastewater](https://doi.org/10.1101/2024.02.15.24302811 "dio: 10.1101/2024.02.15.24302811"). In individual directories for each tool (in [./tools](./tools)), you'll find explanatory READMEs and the scripts we used to prepare reference sets if needed and to run the tool on multiple plates. In general, we tried to use each tool as directed in their documentation, but occasionally alterations were made to ensure we were comparing compatible results. The main goal in each tool directory is to produce aggregated lineages files in the format output by `freyja aggregate`. Scripts and jupyter notebooks for plotting and further anlysis can be found (eventually) in [./plot](./plot), but some of these files are still being compiled from the locations where they were originally used.

These scripts make the following assumptions:
1. All relevant conda environments exist in [./conda](./conda). See the [conda README](conda/README.md) for details.
2. ONT sequencing results exist as output by our [covid-analysis](https://github.com/enviro-lab/covid-analysis) in [./ont](./ont) with directories for each plate named like "MixedControl-${plate}-fastqs".
3. Any software downloaded for a tool to run goes into [./software](./software), but these are not included in the repo.
4. Your current working directory is this repo: `/path/to/benchmark-deconvolute`. Since all shell scripts use relative paths, you should cd to this directory before running anything.

NOTE: Everything in here has been adapted and edited from scripts in a slightly different directory structure. Paths have been adjusted in scripts so that they should work. Not all have been tested, so issues with paths may arise. If you run into any issues, please let us know.

## Dataset
We compared sequencing results generated for control mixtures spiked into water background (WB), SARS-CoV-2 negative wastewater RNA extract background (NWRB) and SARS-CoV-2 positive wastewater RNA extract background (PWRB) for each of two differt primer schemes. Our sequencing data (fasta reads and metadata) can be found under the NCBI BioProject accession [PRJNA1031245](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1031245). All of this is described in more detail in our preprint which is available via the doi [10.1101/2024.02.15.24302811](https://www.medrxiv.org/content/10.1101/2024.02.15.24302811v1.full).

### What variables did we tinker with?
Our control mixtures were spiked into three different background types as decribed below:
Background | Description
--- | ---
WB | water background
NWRB | SARS-CoV-2 negative wastewater RNA extract background
PWRB | SARS-CoV-2 positive wastewater RNA extract background

Two different primer schemes were used to get a full picture of any differences that might arise from scheme choice.
Primer scheme | 
--- | 
[Artic V4.1](https://github.com/joshquick/artic-ncov2019/tree/master/primer_schemes/nCoV-2019/V4.1) |
[VarSkip V2a](https://github.com/nebiolabs/VarSkip/tree/main/schemes/NEB_VarSkip/V2a) |

### Description of each of our plates

The below table shows which background and primer scheme was used for each plate.

Plate | Background | Primer scheme
--- | --- | ---
05-05-23-A41 | WB | Artic
05-05-23-V2 | WB | Varskip
05-16-23-A41 | NWRB | Artic
06-16-23-V2 | NWRB | Varskip
06-26-23-A41 | PWRB | Artic
07-12-23-V2A | PWRB | Varskip

## Deconvolution tools compared
* [Alcov](https://github.com/Ellmen/alcov)
* [Freyja](https://github.com/andersen-lab/Freyja)
* [Kallisto](https://github.com/pachterlab/kallisto) via [wastewater_analysis](https://github.com/baymlab/wastewater_analysis)
* [Lineagespot](https://github.com/npechl/lineagespot)
* [LCS](https://github.com/rvalieris/LCS)
* [LolliPop](https://github.com/cbg-ethz/lollipop)
* [VaQuERo](https://github.com/fabou-uobaf/VaQuERo)

## Configuration parameters and details on variations from standard usage
### Alcov
Default settings were used for Alcov to determine relative abundance. For input, it requires a folder of bam files and a .txt file that has a list of the paths for each of the .bam files and their names.
### Freyja
Our Freyja results came from running `freyja variants` with default settings and `freyja demix` with the --confirmedonly flag on our sequencing data in order to exclude unconfirmed lineages.
### Kallisto
As a repurposed metagenomics tool, kallisto requires the user to create a new index for use in lineage determination. A randomized selection of 100 lineages was chosen for each lineage with at least 500 occurrences in a USA subset of GISAID metadata (Khare et al, 2021) downloaded in September of 2023, and the associated fasta sequences were fed into the pipeline described in the GitHub repo wastewater_analysis (Baaijens, 2021) which uses `kallisto index` to create an index file from the reference set before quantifying lineage proportions present in each sample. Additionally, our kallisto results were compared to those produced when running C-WAP.
### Lineagespot
While lineagespot includes reference files for 13 pangolin lineages, we needed to be able to predict the presence of lineages not among that group. We added in over 2000 other lineages that had appeared at high prevalence levels at any time in the USA, as reported by in the GISAID metadata described in the kallisto section above. Lineages were downloaded using R-outbreak-info’s (Outbreak-Info, 2023) tool getMutationsByLineage and were converted to Lineagespot’s input format using a custom script. Lineagespot relies on allele frequency details from the input .vcf file. ARTIC .bam files were converted to .vcf files with bcftools and SnpEff (Cingolani, 2012) was used to annotate the .vcf to the required format. The output was filtered so that only mutations present in the original ARTIC .vcf remained in the final .vcf provided to Lineagespot. 
### LCS
To download recent, public mutation information, LCS was run with the config setting markers=ucsc, and the file `LCS/rules/config.py` was edited so that `PB_VERSION='2023-07-24'` and `PRIMERS_FA='data/V4_primers.fa'`, where the primers fasta contained sequences corresponding to the ARTIC v4 primers used in sequencing; this provided twenty-six lineages. LCS outputs lineages with the WHO lineage name (if available) separated by an underscore from the pangolin lineage assignment (e.g. Gamma_P.1 or AV.1) and occasionally trailed with another sublineage (e.g. Epsilon_B.1.427_429). Lineages like the latter example where the pangolin lineage was unclear were considered in part of the “Other” category, which contained any unassigned lineages, but otherwise, the pangolin lineage was used for analyses.
### LolliPop
LolliPop differs from most of the other tools in that it considers time series. Given that some of our mixtures combine lineages that did not exist at the same time as each other, LolliPop was configured to ignore time by adding “no_date: True” to the variants-config file. Because LolliPop is interested in portraying lineage proportions for a given location, each sample name was used as a different location in the locations_list of the variants-config file, and location and sample name were used interchangeably in further analyses. LolliPop outputs lower and upper bounds along with its estimated lineage proportions; only the proportions were considered when aggregating results to compare with other tools. Like Lineagespot, LolliPop’s initial reference set is small, only containing eleven lineages, so additional lineages were acquired as recommended by the LolliPop authors from PHE Genomic's Standardised Variant Definitions (SVDs) (Bull, et al, 2023), which lists thirty-four lineages (including the original eleven), and `cojac phe2cojac` (Jahn et al, 2022) was used to convert to the format used by LolliPop. Because of the small size of the SVDs, LolliPop had the least comprehensive dataset of lineages to detect compared to the other tools.
### VaQuERo
Like LolliPop, VaQuERo, by default, considers location and date in lineage assignment. To avoid this behavior, the parameter --smoothingsamples was set to 0, and the dates for each mixture in the metadata provided to VaQuERo were all set three days apart, since all locations were set equivalent. VaQuERo relies on allele frequency details from the input .vcf file. Since the ARTIC pipeline does not include this in the output .vcf, each mixture’s .bam output from ARTIC was run through LoFreq (Wilm et al, 2012), a variant caller mentioned in the VaQuERo documentation, which outputs allele frequencies in the output .vcf, and this file was used for analysis.

Each tool compared in this analysis had its own output format. To make our outputs comparable, they were converted to the same output format used by Freyja. Pangolin lineages provided by each tool were summarized in the same manner derived from the way Freyja summarized lineages, but with a few categories adjusted to better illustrate the proportions of relevant lineages and sublineages; most notably, BA.1, BA.2, BA.4, and BA.5 and their sublineages were grouped separately rather than remaining a single large Omicron category.

## Reproducing our results

### Download our fastqs
To get the relevant fastq files from NCBI, run:
```bash
bash /projects/enviro_lab/decon_compare/benchmark-deconvolute-redo/ont/populate_ont_read_from_local.sh
```

### Conda
Most tools have conda environments. To set those up, see the [conda README](conda/README.md).

### Running individual tools
Most tools have a single script (*labeled something like run_tool_multi.sh*) that can be run to analyze all six plates. Each tool directory contains a README.md (in `./tools/[tool_name]/README.md`) with instructions on how to prepare any necessary datasets and run the tool to analyze everything. kallisto is more complicated and requires the running of several scripts to prepare a database and finally analyze the data.

### Plotting/analyzing results
The plots and statistical analyses from our manuscript can be produced with scripts in [./plots](./plots/) and [./analysis](./analysis/).

## Citation
If you use this dataset in your research, please reference our manuscript:

Jannatul Ferdous Moon, Samuel Kunkleman, William Taylor, April Harris, Cynthia Gibas, Jessica Schlueter. "A Gold Standard Dataset for Lineage Abundance Estimation from Wastewater". *medRxiv* (2024). doi: https://doi.org/10.1101/2024.02.15.24302811
