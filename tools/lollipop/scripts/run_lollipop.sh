#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-individual        # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --mail-user=$USER@uncc.edu        # Job queue to submit this script to
#SBATCH --mail-type=END,FAIL        # Job queue to submit this script to
#SBATCH --output=ont/slurm/lollipop_runs-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

calulate_platewise_mutations()
{
    # loop through alignments for individual samples to collect mutation info
    xsv select 'Sample ID,Sequence date' "${eml}" | xsv fmt -t "\t" | sed '1d' | while read sample_id coll_date; do

        bam=$(realpath "${plate_dir}/output/alignments/${sample_id}"*.bam)
        bscnt_tsv="$bc_dir/${sample_id}.basecnt.tsv.gz"
        tmp_mut_tsv="$mut_dir/${sample_id}.mut.tsv.tmp"
        mut_tsv="$mut_dir/${sample_id}.mut.tsv"

        echo sample: ${sample_id} ${plate}

        # get alignment info as basecount file
        echo "creating basecount tsv - ${sample_id} - ${plate}"
        aln2basecnt --first 1 --basecnt "$bscnt_tsv" --coverage ${bc_dir}/${sample_id}.coverage.tsv.gz --name "${sample_id}" "${bam}"
        echo "${sample_id} ${plate}: exit code: $?"

        # search basecount TSV for mutations of interest (in $mutlist)
        echo "getting mutations - ${sample_id} - ${plate}"
        lollipop getmutations from-basecount --based 1 --output ${tmp_mut_tsv} --location ${sample_id} --date ${coll_date} -m ${mutlist} -- ${bscnt_tsv}

        # add leading column with sample name to mutation file that we just created
        head -1 "${tmp_mut_tsv}" | sed 's/^/sample\t/g' > ${mut_tsv}
        sed '1d' "${tmp_mut_tsv}" | sed "s/^/$sample_id\t/g" >> ${mut_tsv}
        rm ${tmp_mut_tsv}

        echo "##########################################################################"; echo 

    done
}

function runPlate()
{
    set -eu
    plate_dir=ont/MixedControl-${plate}-fastqs
    location="CLT"
    eml="${plate_dir}/MixedControl-${plate}.csv"
    # echo "EML: ${eml}"
    bc_dir=${outdir}/${plate}/basecnt
    mkdir -p $bc_dir && chgrp enviro_lab $bc_dir && chmod g+w $bc_dir
    mut_dir=${outdir}/${plate}/mutations
    mkdir -p $mut_dir && chgrp enviro_lab $mut_dir && chmod g+w $mut_dir
    tallymut=${outdir}/${plate}/tallymut.tsv
    decon_dir=${outdir}/${plate}/deconvolute
    mkdir -p $decon_dir && chgrp enviro_lab $decon_dir && chmod g+w $decon_dir
    conda activate conda/env-lollipop

    # # get mutation info for all plates
    # calulate_platewise_mutations

    # # concat mutation tsvs
    # echo "combining mutation info - $plate"
    # xsv cat rows --output $tallymut $mut_dir/*.mut.tsv
    
    # # cd $decon_dir
    # lolli_dir=software/LolliPop
    # echo "Running deconvolution"

    # # This is the command that has successfully been run
    # lollipop deconvolute \
    #     --output ${decon_dir}/deconvoluted.csv \
    #     --out-json ${decon_dir}/deconvoluted_upload.json \
    #     --deconv-config ${deconv_config} \
    #     --variants-config ${variants_pangolin} \
    #     --fmt-columns \
    #     --seed=42 \
    #     -- ${tallymut}
    #     # --variants-dates ${variant_dates} \
    # echo "Results in "
    # echo "  - ${decon_dir}/deconvoluted.csv"
    # echo "  - ${decon_dir}/deconvoluted_upload.json"
    # conda deactivate

    # Aggregate to freyja-like tsv
    conda activate conda/env-plot
    python tools/lollipop/scripts/aggregate_predictions.py -f ${decon_dir}/deconvoluted.csv -o ${agg_dir}/lollipop-${plate}.tsv
}



# run lollipop for plate
plate=${1}
mutlist=${2}
variants_pangolin=${3}
deconv_config=${4}
outdir=${5}
agg_dir=${6}
runPlate
echo "Lollipop complete: ${plate}"