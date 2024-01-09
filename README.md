# benchmark-deconvolute
Benchmark Dataset for Evaluation & COmparison of Nifty, Versatile, Objective Lineage-Unscrambling-Tool Execution

## About
This repo is designed to house repeatable explanations for the processes we used to compare SARS-CoV-2 lineage deconvolution tools on a standard dataset for our preprint [A gold standard dataset for lineage abundance estimation from wastewater](https://#TODO/add/doi "Not yet available"). In individual directories for each tool (in [./tools](./tools)), you'll find explanatory READMEs and the scripts we used to prepare reference sets if needed and to run the tool on multiple plates. In general, we tried to use each tool as directed in their documentation, but occasionally alterations were made to ensure we were comparing compatible results. The main goal in each tool directory is to produce aggregated lineages files in the format output by `freyja aggregate`.

These scripts make the following assumptions:
1. All relevant conda environments exist in [./conda](./conda). See the [README](conda/README.md) for details.
2. ONT sequencing results exist as output by our [covid-analysis](https://github.com/enviro-lab/covid-analysis) in [./ont](./ont) with directories for each plate named like "MixedControl-${plate}-fastqs".
3. Any software downloaded for a tool to run exists in [./software](./software)
4. Your current working directory is this repo: `/path/to/benchmark-deconvolute`, since all shell scripts use relative paths

NOTE: Everything in here has been adapted and edited from scripts in a slightly different directory structure. Paths have been adjusted in scripts so that they should work, but, because nothing was specifically run from this directory structure, issues with paths may arise.

## Tools compared
* [Alcov](https://github.com/Ellmen/alcov)
* [Freyja](https://github.com/andersen-lab/Freyja)
* [Kallisto](https://github.com/pachterlab/kallisto)
* [Lineagespot](https://github.com/npechl/lineagespot)
* [LCS](https://github.com/rvalieris/LCS)
* [LolliPop](https://github.com/cbg-ethz/lollipop)
* [VaQuERo](https://github.com/fabou-uobaf/VaQuERo)

## Configuration parameters and details on variations from standard usage
### Alcov
Default settings were used for Alcov to determine relative abundance. For input, it requires a folder of bam files and a .txt file that has a list of the paths for each of the .bam files and their names.
### Freyja
Our Freyja results came from running the CDC’s C-WAP pipeline, which uses default settings for the `freyja variants` step and employs the --confirmedonly flag in the `freyja demix` step in order to exclude unconfirmed lineages.
### Kallisto
As a repurposed metagenomics tool, kallisto requires the user to create a new index for use in lineage determination. A randomized selection of 100 lineages was chosen for each lineage with at least 500 occurrences in a USA subset of GISAID metadata (Khare et al, 2021) downloaded in September of 2023, and the associated fasta sequences were fed into the pipeline described in the GitHub repo wastewater_analysis (Baaijens, 2021) which uses `kallisto index` to create an index file from the reference set before quantifying lineage proportions present in each sample.
### Lineagespot
While lineagespot includes reference files for 13 pangolin lineages, we needed to be able to predict the presence of lineages not among that group. We added in over 2000 other lineages that had appeared at high prevalence levels at any time in the USA, as reported by in the GISAID metadata described in the kallisto section above. Lineages were downloaded using R-outbreak-info’s (Outbreak-Info, 2023) tool getMutationsByLineage and were converted to Lineagespot’s input format using a custom script. Lineagespot relies on allele frequency details from the input .vcf file. ARTIC .bam files were converted to .vcf files with bcftools and SnpEff (Cingolani, 2012) was used to annotate the .vcf to the required format. The output was filtered so that only mutations present in the original ARTIC .vcf remained in the final .vcf provided to Lineagespot. 
### LCS
To download recent, public mutation information, LCS was run with the config setting markers=ucsc, and the file LCS/rules/config.py was edited so that PB_VERSION='2023-07-24' and PRIMERS_FA='data/V4_primers.fa', where the primers fasta contained sequences corresponding to the ARTIC v4 primers used in sequencing; this provided twenty-six lineages. LCS outputs lineages with the WHO lineage name (if available) separated by an underscore from the pangolin lineage assignment (e.g. Gamma_P.1 or AV.1) and occasionally trailed with another sublineage (e.g. Epsilon_B.1.427_429). Lineages like the latter example where the pangolin lineage was unclear were considered in part of the “Other” category, which contained any unassigned lineages, but otherwise, the pangolin lineage was used for analyses.
### LolliPop
LolliPop differs from most of the other tools in that it considers time series. Given that some of our mixtures combine lineages that did not exist at the same time as each other, LolliPop was configured to ignore time by adding “no_date: True” to the variants-config file. Because LolliPop is interested in portraying lineage proportions for a given location, each sample name was used as a different location in the locations_list of the variants-config file, and location and sample name were used interchangeably in further analyses. LolliPop outputs lower and upper bounds along with its estimated lineage proportions; only the proportions were considered when aggregating results to compare with other tools. Like Lineagespot, LolliPop’s initial reference set is small, only containing eleven lineages, so additional lineages were acquired as recommended by the LolliPop authors from PHE Genomic's Standardised Variant Definitions (SVDs) (Bull, et al, 2023), which lists thirty-four lineages (including the original eleven), and `cojac phe2cojac` (Jahn et al, 2022) was used to convert to the format used by LolliPop. Because of the small size of the SVDs, LolliPop had the least comprehensive dataset of lineages to detect compared to the other tools.
### VaQuERo
Like LolliPop, VaQuERo, by default, considers location and date in lineage assignment. To avoid this behavior, the parameter --smoothingsamples was set to 0, and the dates for each mixture in the metadata provided to VaQuERo were all set three days apart, since all locations were set equivalent. VaQuERo relies on allele frequency details from the input .vcf file. Since the ARTIC pipeline does not include this in the output .vcf, each mixture’s .bam output from ARTIC was run through LoFreq (Wilm et al, 2012), a variant caller mentioned in the VaQuERo documentation, which outputs allele frequencies in the output .vcf, and this file was used for analysis.

Each tool compared in this analysis had its own output format. To make our outputs comparable, they have been converted to the same output format used by Freyja. Pangolin lineages provided by each tool were summarized in the same manner derived from the way Freyja summarized lineages, but with a few categories adjusted to best illustrate the proportions of relevant lineages and sublineages; most notably, BA.1, BA.2, BA.4, and BA.5 and their sublineages were grouped separately rather than remaining a single large Omicron category.
