#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-test          # User-defined name for job
#SBATCH --partition=Draco        # Job queue to submit this script to
#SBATCH --mail-user=$USER@uncc.edu        # Job queue to submit this script to
#SBATCH --mail-type=END,FAIL        # Job queue to submit this script to
#SBATCH --output=tools/lollipop/slurm/%j.out
umask 007
module purge
module load anaconda3
set -eu

function lolli() {
    conda activate software/conda/env-lollipop
    echo CMD: lollipop "${@}"
    lollipop "${@}"
    conda deactivate
}
function a2b() {
    conda activate software/conda/env-sgu
    echo CMD: aln2basecnt "${@}"
    aln2basecnt "${@}"
    conda deactivate
}
function runPlate() # plate
{
    plate="$1"
    plate_dir=ont/MixedControl-${plate}-fastqs
    location="CLT"
    eml="${plate_dir}/MixedControl-${plate}.csv"
    # echo "EML: ${eml}"
    bc_dir=tools/lollipop/output/${plate}/basecnt
    mkdir -p $bc_dir && chgrp enviro_lab $bc_dir && chmod g+w $bc_dir
    mut_dir=tools/lollipop/output/${plate}/mutations
    mkdir -p $mut_dir && chgrp enviro_lab $mut_dir && chmod g+w $mut_dir
    tallymut=tools/lollipop/output/${plate}/tallymut.tsv
    decon_dir=tools/lollipop/output/${plate}/deconvolute
    mkdir -p $decon_dir && chgrp enviro_lab $decon_dir && chmod g+w $decon_dir

    # loop through alignments for individual samples to collect mutation info
    xsv select 'Sample ID,Sequence date' "${eml}" | xsv fmt -t "\t" | sed '1d' | while read sample_id coll_date; do

        bam="${plate_dir}/output/samples/${sample_id}.primertrimmed.rg.sorted.bam"
        bscnt_tsv="$bc_dir/${sample_id}.basecnt.tsv.gz"
        tmp_mut_tsv="$mut_dir/${sample_id}.mut.tsv.tmp"
        mut_tsv="$mut_dir/${sample_id}.mut.tsv"

        echo sample: ${sample_id} ${plate}

        # get alignment info as basecount file
        echo "creating basecount tsv - ${sample_id} - ${plate}"
        a2b --first 1 --basecnt "$bscnt_tsv" --coverage ${bc_dir}/${sample_id}.coverage.tsv.gz --name "${sample_id}" "${bam}"

        # search basecount TSV for mutations of interest (in $mutlist)
        echo "getting mutations - ${sample_id} - ${plate}"
        lolli getmutations from-basecount --based 1 --output ${tmp_mut_tsv} --location ${sample_id} --date ${coll_date} -m ${mutlist} -- ${bscnt_tsv}

        # add leading column with sample name to mutation file that we just created
        head -1 "${tmp_mut_tsv}" | sed 's/^/sample\t/g' > ${mut_tsv}
        sed '1d' "${tmp_mut_tsv}" | sed "s/^/$sample_id\t/g" >> ${mut_tsv}
        # mv temp.mut "${mut_tsv}"
        # exit 1

        echo "##########################################################################"; echo 

    done

    # concat mutation tsvs
    echo "combining mutation info - $plate"
    xsv cat rows --output $tallymut $mut_dir/*.mut.tsv

    # ## NOTE:
    # The `lollipop generate-mutlist` step created 'variants_pangolin.yaml'.
    # The contents have been added manually to 'var_config_custom.yaml'
    
    cd $decon_dir
    lolli_dir=software/LolliPop
    echo "Running deconvolution"

    # This is the command that has successfully been run
    lolli deconvolute \
        --output ${decon_dir}/deconvoluted.csv \
        --out-json ${decon_dir}/deconvoluted_upload.json \
        --deconv-config ${lolli_dir}/presets/deconv_bootstrap_cowwid.yaml \
        --variants-config ${variants_pangolin} \
        --variants-dates ${variant_dates} \
        --fmt-columns \
        --seed=42 \
        -- ${tallymut}
    echo "Results in "
    echo "  - ${decon_dir}/deconvoluted.csv"
    echo "  - ${decon_dir}/deconvoluted_upload.json"

    # Aggregate to freyja-like tsv
    conda activate software/conda/env-plot
    python tools/lollipop/scripts/aggregate_predictions.py -f ${decon_dir}/deconvoluted.csv -o ${decon_dir}/deconvoluted.agg.csv
}



vocs=tools/lollipop/config_data/variant_definitions/vocs
gff=tools/lollipop_1/initial_data/GCF_009858895.2_ASM985889v3_genomic.gff
mkdir -p tools/lollipop/mutlists

# create list of mutations of interest
mutlist=tools/lollipop/mutlists/mutlist.tsv
variants_pangolin=tools/lollipop/mutlists/variants_pangolin.yaml
echo creating mutlist
lolli generate-mutlist \
    --output ${mutlist} \
    --out-pangovars ${variants_pangolin} \
    --genes ${gff} -- \
    $vocs/*
# comment out extra B.1.1.7
sed -i 's/uncr/#uncr/' ${variants_pangolin}
# Add to variants_pangolin
echo "" >> ${variants_pangolin}
echo "start_date: '2023-03-01'" >> ${variants_pangolin}
echo "end_date: '2023-04-01'" >> ${variants_pangolin}
echo "" >> ${variants_pangolin}
echo "to_drop:" >> ${variants_pangolin}
echo " - subset" >> ${variants_pangolin}
echo " - revert" >> ${variants_pangolin}
echo "# - shared" >> ${variants_pangolin}
echo "" >> ${variants_pangolin}
echo "locations_list:" >> ${variants_pangolin}
echo " - CLT" >> ${variants_pangolin}


num=1 # note: 1 uses all vocs produced by tools/lollipop/scripts/get_custom_variant_definitions.sh
cd tools/lollipop
mutlist=tools/lollipop/mutlists/mutlist.tsv
variants_pangolin=tools/lollipop/mutlists/variants_pangolin.yaml
# variants_pangolin has `no_date: true`, so the variant_dates file is not really used
variant_dates=tools/lollipop/config_data/variant_definitions/varaint_dates.yaml

plates='05-05-23-A41 05-16-23-A41 06-26-23-A41 05-05-23-V2 06-16-23-V2 07-12-23-V2A'

for p in $plates; do
    ( runPlate $p ) &
done
wait
