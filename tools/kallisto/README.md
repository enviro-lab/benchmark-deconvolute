# Preparing for and running kallisto

## Building a reference set to use for kallisto variant calling

Based on [wastewater_analysis: Building a Reference Set](https://github.com/baymlab/wastewater_analysis#building-a-reference-set). Some of their scripts are adapted here.

The script used to actually run these steps is here: [tools/kallisto/scripts/run_analysis.sh](tools/kallisto/scripts/run_analysis.sh)

### Useful conda envs:
1. 
```
mamba create -p conda/env-kallisto-variants -c bioconda -c defaults pyvcf vcftools bcftools minimap2 kallisto py-bgzip
```
2. 
```
mamba create -p conda/env-preprocess -c bioconda pyvcf
conda install python=3.7 # this upgrades pyvcf to python3.7 and avoids a datetime bug
pip install pandas
```

## General Steps:
Below are the general steps taken to use kallisto for deconvolution. 

#### Step 1: Aquire GISAID EpiCov metadata
1. Log in to [EpiCoV](https://www.epicov.org/epi3/frontend)
2. Click `Downloads`
3. In 'Download packages', click `metadata`
4. Move metadata*.tar.xz somewhere useful like './gisaid_data/metadata.tar.xz' (refered to henceforth as `metadata.tar.xz`)
   a. optionally, filter the original metadata tar file so this isn't as huge for later parsing.
5. Run the following:
```bash
meta=metadata.tar.xz
reference_set=tools/kallisto/reference_set
python tools/kallisto/scripts/script1_determine_reference_set.py -m ${meta} --min_seqs_per_lin 500 -k 100 --seed 0 --country USA -o ${reference_set}
# NOTE: this may have a couple samples from non-human hosts, too. Filter those out manually.
```
   * outputs:
     * epicov_accessions.csv            Accessions of samples in reference set
     * selection_dict.json              json.dumps version of selection_dict - used in step 2
     * lineage.txt                      List of lineages and how many sequences exist for each

#### Step 2: Download fastas for selected reference set and store them in `tools/kallisto/reference_set`
Using the output from Step 1, download the listed sample's fastas. If there are more than 10,000 samples, the list will need to be split into smaller chunks. This can be done with split, which produces 'gisaid_accessionsaa', 'gisaid_accessionsab', ...
```bash
split -l 10000 ${reference_set}/gisaid_accessions.csv gisaid_accessions
```
For each file listing accessions, do the following:
1. In EpiCoV, click `Search`
2. Click `Select`
3. Click `Choose file`
4. Select 'epicov_accessions.csv'
5. Click `Download`
6. Select `Nucleotide Sequences (FASTA)`
7. Agree to `Terms of Use`
8. Click `Download`

#### Step 3: Write final fasta files in useful locations1
##### 1. Get a complete fasta file at 'gisaid_data/gisaid.fasta'
If only one fasta file was downloaded, move 'gisaid_hcov-19_*.fasta' somewhere useful like 'tools/kallisto/reference_set' (refered to henceforth as `gisaid_data/gisaid.fasta`).
Otherwise, if the accessions were split into chunks, the fasta files should be concatenated via something like this: 
```
cat gisaid_*.fasta > gisaid_data/gisaid.fasta
```
##### 2. Write individual fastas into lineage-specific folders
Run the following to write the fasta files in the desired locations.
```bash
fasta=tools/kallisto/gisaid_data/gisaid.fasta
python tools/kallisto/scripts/script2_write_fastas.py -f ${fasta} -o ${reference_set}
```
   * outputs:
     * gisaid_data/metadata.tsv            
     <!-- * gisaid_data/gisaid.fasta          -->

### Running steps 4-6
Run `bash tools/kallisto/scripts/script3_prepare_reference_set.sh` to finalize/index the reference set. This include the below steps 4, 5, and 6.

#### Step 4: Call variants (reference set vs reference)
Run `bash tools/kallisto/wastewater_analysis/pipeline/call_variants.sh ${reference_set} <full_path_to_main_ref_fasta>`

#### Step 5: Select samples
Run `python tools/kallisto/wastewater_analysis/pipeline/select_samples.py -m metadata.tsv -f sequences.fa -o ${reference_set} --vcf ${reference_set}/*_merged.vcf.gz --freq ${reference_set}/*_merged.frq`

#### Step 6: Create index for reference set
Run `kallisto index -i ${reference_set}/sequences.kallisto_idx ${reference_set}/sequences.fasta`

### Running steps 7-9
Run `tools/kallisto/scripts/script4_run_kallisto_multi.sh` to analyze each sample and aggregate the results. This include the below steps 7, 8, and 9.

#### Step 7: Qualify sample variance/abundance acoss reference set
 1. For each sample, run `kallisto quant -i ${reference_set}/sequences.kallisto_idx -o "output/${sample_name}" --single -l 568 -s 30 "${sample_fastq}"`

 2. (Optional, not used in pipeline) Find mean and standard deviation of fragment length (using filtered read length and hoping that's okay) for kallisto via:
 ```bash
 $ python tools/kallisto/scripts/getReadStats.py < <(zcat ont/MixedControl-06-16-23-V2-fastqs/output/porechop_kraken_trimmed/Mixture*.fastq.gz)
 ```
 Output for our samples:
 ```bash
 Mean: 568.4047163628063
 Standard deviation: 29.772089400674048
 ```

#### Step 8: Get variant abundance estimates
1. (Optional) Select VOCs like `vocs='B.1.1.7,B.1.351,B.1.427,B.1.429,B.1.526,P.1'`. NOTE: we skipped selecting specific vocs to allow for all available lineages.
2. For each sample, run `python tools/kallisto/wastewater_analysis/pipeline/output_abundances.py -m <min_ab> -o <outdir>/predictions.tsv --metadata ${reference_set}/metadata.tsv --voc $vocs <outdir>/abundance.tsv`

#### Step 9: Aggregate results like freyja does for easy plotting/analysis
python scripts/aggregate_predictions.py -f kallisto/quant/*/predictions.tsv -o kallisto/kallisto_aggregated_abundance.tsv

## Actual use:
1. Do steps 1 - 3 semi-manually as described above.
2. Run steps 4 - 6 above via `tools/kallisto/scripts/script3_prepare_reference_set.sh`
3. Run steps 7 - 9 above via `tools/kallisto/scripts/script4_run_kallisto_multi.sh`
