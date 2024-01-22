# How we compiled kallisto results from C-WAP

1. Use C-WAP to analyze filtered reads

    C-WAP uses the following commands internally:
    ```
    kallisto quant \
        --index $projectDir/customDBs/variants.kalIdx \
        --output-dir ./ \
        --plaintext \
        --threads 2 \
        --single \
        -l 300 \
        -s 50 \
        resorted.fastq.gz
   ```

2. Run `tools/kallisto-cwap/scripts/compile_predictions.sh` to get results from C-WAP and convert them to the freyja demix format.