#!/usr/bin/env python3

import sys
from pathlib import Path
import pandas as pd
from argparse import ArgumentParser
from freyja_plot.freyja_plot import get_lineage_summary

def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Writes out predicted kallisto lineage abundances like freyja aggregated output")
    parser.add_argument("-f",dest="prediction_files",type=Path,nargs="*",help="List of prediction files to aggregate into output.")
    parser.add_argument("-o",dest="outfile",type=Path,help="Output tsv filename.")
    return parser.parse_args()

def getPredictionDf(file):
    """Returns predictions.tsv (`file`) as dataframe sorted descending by adjusted frquency"""

    sample = file.parent.name
    df = pd.read_csv(file,sep="\t",header=2).rename(columns={"# variant":"variant"})
    df["sample_name"] = sample
    df = df.sort_values(by="adj_freq(%)",ascending=False)
    return df

def writeLineageAbundanceFile(outfile, prediction_files):
    """Aggregates all `prediction_files` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for file in prediction_files:
            df = getPredictionDf(file)
            df = df[df["adj_freq(%)"]>0.0]
            sample_name = str(df["sample_name"].unique().squeeze())

            lineage_list = list(df["variant"])
            lineages = " ".join(lineage_list)
            # print(df["adj_freq(%)"])
            abundance_list = list(df["adj_freq(%)"].apply(lambda x: round(x/100, 4)))
            abundances = " ".join((str(x) for x in abundance_list))
            resid = ""
            coverage = ""

            summarized = get_lineage_summary(lineage_list, abundance_list)

            out.write(f"{sample_name}\t{summarized}\t{lineages}\t{abundances}\t{resid}\t{coverage}\n")


    
def main():
    """Compiles predictions data for analysis"""

    args = parseArgs()
    writeLineageAbundanceFile(args.outfile, args.prediction_files)
    print("Predictions written to:",args.outfile)

if __name__ == '__main__':
    sys.exit(main())