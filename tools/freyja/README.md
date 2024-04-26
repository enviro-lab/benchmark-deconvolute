# How we compiled Freyja results

1. Run `tools/freyja/scripts/run_freyja_multi.sh` from the root of this repo to run freyja for all samples in each plate.
   * To seperately schedule each freyja job via slurm, make sure the slurm portion is uncommented in [tools/freyja/scripts/run_freyja_multi.sh](scripts/run_freyja_multi.sh).

Results will be in [tools/freyja/agg/](./agg/)
