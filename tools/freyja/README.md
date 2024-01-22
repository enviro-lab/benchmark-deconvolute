# How we compiled Freyja results

1. Use C-WAP to analyze filtered reads

    C-WAP uses the following commands internally:
    ```
    freyja variants resorted.bam --variants freyja.variants.tsv --depths freyja.depths.tsv --ref $params.referenceSequence
    freyja demix freyja.variants.tsv freyja.depths.tsv --output freyja.demix --confirmedonly
    ```

2. Copy C-WAP's `freyja.demix` files to `tools/freyja/MixedControl_output/demixed/demixed_${plate}`

3. Run `tools/freyja/scripts/collect_agg_files.sh` to aggregate results
