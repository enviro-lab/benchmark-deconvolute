# How we compiled kallisto results from C-WAP

1. Use C-WAP to analyze filtered reads

    C-WAP uses roughly the following commands internally:
    ```
    kraken2 resorted.fastq.gz \
        --db $projectDir/customDBs/majorCovidDB \
        --threads $numThreads \
        --report k2-majorCovid.out > /dev/null
    bracken \
        -d $projectDir/customDBs/majorCovidDB \
        -i k2-majorCovid.out \
        -o majorCovid.bracken \
        -l C
   ```

2. Run `tools/kraken2-cwap/scripts/compile_predictions.sh` to get results from C-WAP and convert them to the freyja demix format.