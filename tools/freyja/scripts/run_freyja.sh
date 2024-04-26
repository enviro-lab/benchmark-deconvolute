#!/usr/bin/env bash
#SBATCH --time=04:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1    # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           	# Maximum physical memory to use for job
module purge
module load anaconda3 &>/dev/null || source "$(dirname $(which conda))/../etc/profile.d/conda.sh" || (echo 'make sure you have conda installed'; exit 1)
set -eu

ref="${1}"
bam="${2}"
outdir="${3}"
sample="${4}"

conda activate conda/env-plot
mkdir -p ${outdir}/variants ${outdir}/demixed
variants=${outdir}/variants/${sample}_freyja-variants.tsv
depths=${outdir}/variants/${sample}_freyja-depths.tsv
demixed=${outdir}/demixed/${sample}_freyja-demix.tsv

# run freyja
echo "running freyja for $sample"
echo "running freyja variants"
freyja variants ${bam} --variants ${variants} --depths ${depths} --ref ${ref}
echo "running freyja demix"
freyja demix ${variants} ${depths} --output ${demixed} --confirmedonly

# edit output to have sample name
( echo -e "\t${sample}" && sed '1d' ${demixed} ) > ${demixed}.tmp
mv ${demixed}.tmp ${demixed}