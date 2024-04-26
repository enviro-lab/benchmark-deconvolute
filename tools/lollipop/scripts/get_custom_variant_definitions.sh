#!/usr/bin/env bash
#!/usr/bin/env bash
#SBATCH --time=04:00:00  # Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8     # Number of nodes and processors per node requested by job
#SBATCH --mem=96gb           # Maximum physical memory to use for job
#SBATCH --job-name=lollipop-test          # User-defined name for job
#SBATCH --partition=Draco        # Job queue to submit this script to
#SBATCH --mail-user=$USER@uncc.edu        # Job queue to submit this script to
#SBATCH --mail-type=END,FAIL        # Job queue to submit this script to
#SBATCH --output=ont/slurm/lollipop_prep-%j.out
module purge &>/dev/null
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

# update list of possible ymls
updateList()
{
    if [[ -f $readme_out ]]; then rm $readme_out; fi
    curl -fsSL $readme_url -o $readme_out
}

# input: list of lineages or superlineages
# example input: XBB CH.1 BA.4 BQ.1 BA.5 BA.2
# Downloads associated ymls

getAllLineages()
{
    # for lineage in 
    grep -oP 'href.*[^ |$]' $readme_out | grep "PANGO" | while IFS='|' read label lineage_info description; do
        if [[ $lineage_info = *href* ]]; then
            # extract pango lineage, dropping link or nextstrain info
            lineage=`echo $lineage_info |  tr ',' '\n' | grep PANGO | grep -oP '">\K[A-Z0-9.]*'`
        else
            lineage=`echo $lineage_info | grep -oP 'PANGO: \K.*' | cut -f1`
        fi
        if ! [[ $lineage = Multiple || -z $lineage ]]; then printf "$lineage "; fi
    done
    echo ''
}

downloadFiles() # QUERY[ QUERY2 ...]
{
    # start fresh
    if [[ ! -z "$(ls -A $dnld_dir)" ]]; then rm $dnld_dir/*; fi

    for query in ${@}; do
        echo "Checking for lineages like $query"
        grep -oP 'href.*[^ |$]' $readme_out | grep "$query" | while IFS='|' read label lineage_info description; do
            echo "label: $label"
            echo "description: $description"
            link=$var_defs/`echo $label | grep -oP '"\K.*yml'`
            filebase=`basename $link`
            echo link: $link
            if [[ $lineage_info = *href* ]]; then
                # extract pango lineage, dropping link or nextstrain info
                lineage=`echo $lineage_info |  tr ',' '\n' | grep PANGO | grep -oP '">\K[A-Z0-9.]*'`
            else
                lineage=`echo $lineage_info | grep -oP 'PANGO: \K.*' | cut -f1`
            fi
            echo lineage: $lineage
            outfile=$dnld_dir/${lineage}-${filebase}
            if [[ ! -f $outfile ]]; then
                echo "Downloading to $outfile"
                curl -fsSL $link -o $outfile
                echo
            fi
        done
    done
}

# converts all ymls in directory to format used by lollipop and
convertFiles()
{
    # start fresh
    if [[ ! -z "$(ls -A $outdir)" ]]; then rm $outdir/*; fi

    conda activate conda/env-lollipop
    # convert
    for file in $dnld_dir/*; do
        # check that file has yam["calling-definition"]["probable"]["mutations-required"] or else add it
        echo "Checking file: $file"
        tools/lollipop/scripts/ensure_probable.py $file

        echo "Converting $file"
        cojac phe2cojac $file > $outdir/`basename $file`
    done
}

### main()
# set paths
var_defs=https://raw.githubusercontent.com/ukhsa-collaboration/variant_definitions/main
readme_url=https://raw.githubusercontent.com/ukhsa-collaboration/variant_definitions/main/README.md
var_def_dir="${1}"
readme_out=${var_def_dir}/variant_definition_links.md
dnld_dir=${var_def_dir}/voc_ymls
outdir=${var_def_dir}/vocs
mkdir -p $dnld_dir $outdir

# set lineage choices
# lineages_of_interest="XBB CH.1 BA.4 BQ.1 BA.5 BA.2 B.1.1.529 B.1.1.7 B.1.526 B.1.617.2 BA.1 BA.2 BA.5 BA.4 B.2.12.1 P.1"
lineages_of_interest=`getAllLineages`

# get ymls of interest
updateList
downloadFiles ${lineages_of_interest}

# convert to lollipop format
convertFiles 