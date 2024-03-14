#!/usr/bin/env bash
set -eu

bioproject=PRJNA1031245
declare -A plates=(["05-05-23-A41"]="v4.1-ctrl" ["05-16-23-A41"]="v4.1-neg" ["06-26-23-A41"]="v4.1-pos" ["05-05-23-V2"]="v2a-ctrl" ["06-16-23-V2"]="v2a-neg" ["07-12-23-V2A"]="v2a-pos")

# using sra-tools and entrez-direct (available through conda), collect relevant fastqs for each plate
for plate in ${!plates[@]}; do
    title=${plates[${plate}]}
    echo "$plate: $title"
    esearch -db sra -query $bioproject | esummary | xtract -pattern DocumentSummary -element LIBRARY_NAME,Run@acc | grep $title | while read name srr; do
        # use sra-tools to download associated sample from SRA
        mixture=${name%%-*}
        echo "Downloading $srr ($mixture)"
        prefetch $srr
        fasterq-dump --split-files ${srr}/${srr}.sra
        rm -rf $srr
        if [[ -f ${srr}.fastq.gz ]]; then true
        elif [[ -f ${srr}.fastq ]]; then "zipping up ${srr}.fastq"; gzip ${srr}.fastq
        else echo "Missing fastq for $srr ($mixture)"
        fi
        # write fastq to fastq_pass in correctly labeled barcode directory
        csv=MixedControl-${plate}-fastqs/MixedControl-${plate}.csv
        barcode="`grep $mixture $csv | grep -oP 'barcode[0-9][0-9]'`"
        echo "Detected barcode: $barcode"
        mkdir -p "MixedControl-${plate}-fastqs/fastq_pass/$barcode"
        mv $srr.fastq.gz MixedControl-${plate}-fastqs/fastq_pass/$barcode/$mixture.fastq.gz
    done
done