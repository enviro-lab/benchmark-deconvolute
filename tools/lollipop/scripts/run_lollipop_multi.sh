#!/usr/bin/env bash
#SBATCH --time=24:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-prep          # User-defined name for job
#SBATCH --partition=Nebula        # Job queue to submit this script to
#SBATCH --mail-user=$USER@uncc.edu        # Job queue to submit this script to
#SBATCH --mail-type=END,FAIL        # Job queue to submit this script to
#SBATCH --output=ont/slurm/lollipop_main-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu




create_variants_pangolin() {
    # create list of mutations of interest
    echo creating mutlist
    conda activate conda/env-lollipop
    lollipop generate-mutlist \
        --output ${mutlist} \
        --out-pangovars ${variants_pangolin} \
        --genes ${gff} -- \
        $vocs/*
    conda deactivate

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
    # list out mixture names as locations to make them distinct
    echo "locations_list:" >> ${variants_pangolin}
    for mixture in $(sed '1d' ${mixture_list} | cut -f1); do
        echo " - ${mixture}" >> ${variants_pangolin}
    done
    # NFWs not available via NCBI
    # echo " - NFWA" >> ${variants_pangolin}
    # echo " - NFWC" >> ${variants_pangolin}
    echo "" >> ${variants_pangolin}
    echo "no_date: true" >> ${variants_pangolin}
}


### Main

# important variables
mutlist=tools/lollipop/mutlists/mutlist.tsv
variants_pangolin=tools/lollipop/mutlists/variants_pangolin.yaml
# variants_pangolin has `no_date: true`, so the variant_dates file is not really used
variant_dates=tools/lollipop/config_data/variant_definitions/varaint_dates.yaml
vocs=tools/lollipop/config_data/variant_definitions/vocs
gff=tools/lollipop/initial_data/GCF_009858895.2_ASM985889v3_genomic.gff
mixture_list=expected_abundances/control_only_agg.tsv
agg_dir=tools/lollipop/agg
mkdir -p tools/lollipop/{mutlists,agg}
deconv_config=tools/lollipop/config_data/deconv_config.yaml

# # download deconv-config
# if [[ ! -f tools/lollipop/config_data ]]; then
#     echo "downloading deconv-config"
#     curl -fsSL https://raw.githubusercontent.com/cbg-ethz/LolliPop/main/presets/deconv_bootstrap_cowwid.yaml -o ${deconv_config}
# fi

# # create variant definitions
# if [[ ! -f tools/lollipop/config_data/variant_definitions/variant_definition_links.md ]]; then
#     echo "Creating variant definitions"
#     var_def_dir=tools/lollipop/config_data/variant_definitions
#     python tools/lollipop/scripts/get_custom_variant_definitions.sh ${var_def_dir}
# fi

# # create list of mutations based on variant definitions
# if [[ ! -f ${variants_pangolin} ]]; then
#     create_variants_pangolin
# fi

# run lollipop for each plate
plates='05-05-23-A41 05-16-23-A41 06-26-23-A41 05-05-23-V2 06-16-23-V2 07-12-23-V2A'
for p in $plates; do
    echo "running lollipop for plate: $p"
    slurm_out=ont/slurm/lollipop_runs-${p}-%j.out
    outdir=tools/lollipop/MixedControl_output
    sbatch --output=${slurm_out} tools/lollipop/scripts/run_lollipop.sh $p $mutlist $variants_pangolin $deconv_config $outdir $agg_dir
done