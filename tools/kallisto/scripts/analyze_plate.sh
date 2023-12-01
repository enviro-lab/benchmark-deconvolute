#!/usr/bin/env bash
#SBATCH --time=10:00:00  		# Maximum amount of real time for the job to run in HH:MM:SS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24    # Number of nodes and processors per node requested by job
#SBATCH --mem=8gb           	# Maximum physical memory to use for job
#SBATCH --partition=Orion       # Job queue to submit this script to
set -eu

conda activate conda/env-kallisto-variants

export PATH=tools/kallisto/wastewater_analysis/pipeline:tools/kallisto/usa/reference_set/scripts:$PATH

reference_set=tools/kallisto/reference_set

fastq_dir=$1
outdir=$2

mkdir -p ${outdir}
for sample_fastq in ${fastq_dir}/*.fastq*; do
    # mkdir -p ${outdir}/${sample_name}
    sample_name=`basename $sample_fastq | cut -d'_' -f1`

    # Step 7:
    echo "CMD: kallisto quant -i ${reference_set}/sequences.kallisto_idx -o ${outdir}/${sample_name} --single -l 568 -s 30 ${sample_fastq} -t 24"
    kallisto quant -i ${reference_set}/sequences.kallisto_idx -o ${outdir}/${sample_name} --single -l 568 -s 30 ${sample_fastq} -t 24

    # # Step 8 (with variants specified, NOTE: not used):
    # echo "CMD: python tools/kallisto/wastewater_analysis/pipeline/output_abundances.py -m 0.1 -o ${outdir}/${sample_name}/predictions.tsv --metadata ${reference_set}/metadata.tsv --voc $vocs ${outdir}/${sample_name}/abundance.tsv"
    # python tools/kallisto/wastewater_analysis/pipeline/output_abundances.py -m 0.1 -o ${outdir}/${sample_name}/predictions.tsv --metadata ${reference_set}/metadata.tsv --voc $vocs ${outdir}/${sample_name}/abundance.tsv

    # Step 8 (without variants specified):
    echo "CMD: python tools/kallisto/wastewater_analysis/pipeline/output_abundances.py -m 0.1 -o ${outdir}/${sample_name}/predictions.tsv --metadata ${reference_set}/metadata.tsv ${outdir}/${sample_name}/abundance.tsv"
    python tools/kallisto/wastewater_analysis/pipeline/output_abundances.py -m 0.1 -o ${outdir}/${sample_name}/predictions.tsv --metadata ${reference_set}/metadata.tsv ${outdir}/${sample_name}/abundance.tsv

done

# Step 9: Analzye predictions
conda activate /projects/enviro_lab/software/conda/env-freyja
echo 'CMD: tools/kallisto/scripts/aggregate_predictions.py -f ${outdir}/*/predictions.tsv -o ${outdir}/aggregated_kallisto_abundance.tsv'
tools/kallisto/scripts/aggregate_predictions.py -f ${outdir}/*/predictions.tsv -o ${outdir}/aggregated_kallisto_abundance.tsv