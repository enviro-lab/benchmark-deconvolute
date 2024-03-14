module load anaconda3
conda activate conda/env-plot
set -eu

## returns list of lineages that were more common than a threshold percent (-p) for listed locations (-l)

findLineages()
{
    python tools/lineagespot/scripts/lineage_filter.py "${@}"
}

csv="tools/lineagespot/prepared_metadata.csv"

## various filtration options
# declare -a commands=('-l USA/NC -p 50' '-l USA/NC USA/SC -p 50' '-p 50' '-p 80')
# declare -a commands=('-l USA/NC USA/SC -p 50')
declare -a commands=('-l USA/NC USA/SC -p 20')
# declare -a commands=('-p 50' '-p 80')

for argset in "${commands[@]}"; do
    echo $argset
    findLineages $csv $argset # | wc -l
done
