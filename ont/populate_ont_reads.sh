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
        echo "Downloading $srr ($mixture) ($name)"
        prefetch $srr
        fasterq-dump --split-files ${srr}/${srr}.sra
        rm -rf $srr
        if [[ -f ${srr}.fastq.gz ]]; then true
        elif [[ -f ${srr}.fastq ]]; then "zipping up ${srr}.fastq"; gzip ${srr}.fastq
        else echo "Missing fastq for $srr ($mixture)"
        fi
        # write fastq to porechop_kraken_trimmed
        echo "Writing: $mixture"
        mkdir -p "MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed"
        mv $srr.fastq.gz MixedControl-${plate}-fastqs/output/porechop_kraken_trimmed/$mixture.fastq.gz
    done
done