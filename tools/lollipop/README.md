# Deconvolution via LolliPop

## Documentation:
[Lollipop GitHub](https://github.com/cbg-ethz/LolliPop/tree/main)

## Conda:
```
conda activate software/conda/env-lollipop
```

## Setup:
### Download variant definitions used by Lollipop & Cojac
run: `tools/lollipop/scripts/get_custom_variant_definitions.sh`

## Prepare mutlist of variant signatures, get mutations for each sample, and deconvolute
run: `tools/lollipop/scripts/run_lollipop.sh`

## Edits I had to make to rig something to work
Script: `software/conda/env-sgu/lib/python3.10/site-packages/smallgenomeutilities/__pileup__.py`, 
> line 29, inserted:
> ```python
>                 # deal with missing reads (added by Sam)
>                 if not read.query_sequence:
>                     alignment += ''.join(np.repeat('-', length))
>                     continue
> ```

## Config settings
We set `no_date: True` in the variants_pangolin file because we lacked any date information (since mixtures were all made at the same time with lineages that didn't necessarily occur together).