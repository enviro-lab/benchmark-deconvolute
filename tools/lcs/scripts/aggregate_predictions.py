#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd
from pathlib import Path
from freyja_plot.freyja_plot import get_lineage_summary


def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Converts LSV decompose/*.out TSV to freyja-like format")
    parser.add_argument("--tsv","-f",dest="prediction_file",type=Path,help="Path to LCS decompose tsv output")
    parser.add_argument("--outfile","-o",type=Path,help="Path to use for freyja aggregate style output tsv")
    return parser.parse_args()


def getPangoVariant(variant_group):
    """Returns only the pangolin variant"""

    return variant_group.split("_")[-1]


def getPredictionDfs(prediction_file):
    """Yields dataframes with a single sample from (`prediction_file`) sorted descending by proportion"""

    df = pd.read_csv(prediction_file, sep="\t")
    for sample in df["sample"].unique():
        sdf:pd.DataFrame = df[df["sample"]==sample]
        sdf = sdf.sort_values("proportion", ascending=False)
        sdf["variant"] = sdf["variant_group"].apply(getPangoVariant)
        # sdf["variant"] = sdf["variant_group"].str.split("_")[-1]
        sdf["proportion"] = sdf["proportion"].astype(float)
        sdf = sdf[sdf["proportion"]>0.0001]
        other = 1 - sdf["proportion"].sum()
        yield sample, sdf, other


def writeLineageAbundanceFile(outfile, prediction_file):
    """Converts `prediction_file` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for sample, df, other in getPredictionDfs(prediction_file):

            lineage_list = list(df["variant"]) + ["Other"]
            lineages = " ".join(lineage_list)
            # print(df["proportion"])
            abundance_list = list(df["proportion"].apply(lambda x: round(x, 4))) + [round(other, 4)]
            abundances = " ".join((str(x) for x in abundance_list))
            resid = ""
            coverage = ""

            summarized = get_lineage_summary(lineage_list, abundance_list)

            out.write(f"{sample}\t{summarized}\t{lineages}\t{abundances}\t{resid}\t{coverage}\n")



def main():
    """Converts predictions data for analysis"""

    args = parseArgs()
    writeLineageAbundanceFile(args.outfile, args.prediction_file)
    print("Predictions written to:",args.outfile)
    return


if __name__ == "__main__":
    main()