#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd
from pathlib import Path
from freyja_plot.freyja_plot import get_lineage_summary


def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Converts LSV decompose/*.out TSV to freyja-like format")
    parser.add_argument("--tsv","-f",dest="prediction_file",type=Path,help="Path to VaQuERo csv output")
    parser.add_argument("--outfile","-o",type=Path,help="Path to use for freyja aggregate style output tsv")
    return parser.parse_args()


def getPangoVariant(variant_group):
    """Returns only the pangolin variant"""

    return variant_group.split("_")[-1]


def getPredictionDfs(prediction_file):
    """Yields dataframes with a single sample from (`prediction_file`) sorted descending by proportion"""

    df = pd.read_csv(prediction_file, sep='\t')
    df = df[df["sample_id"].notna()]
    for sample in df["sample_id"].unique():
        sdf:pd.DataFrame = df[df["sample_id"]==sample]
        sdf = sdf.sort_values("value", ascending=False)
        sdf["value"] = sdf["value"].astype(float)
        # sdf = sdf[sdf["value"]>0.0]
        sdf = sdf[sdf["value"]>0.0001]
        # other = 1 - sdf["value"].sum()
        yield sample, sdf #, other


def writeLineageAbundanceFile(outfile, prediction_file):
    """Converts `prediction_file` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for sample, df in getPredictionDfs(prediction_file):

            lineage_list = list(df["variant"]) # + ["Other"]
            lineages = " ".join(lineage_list)
            # print(df["value"])
            abundance_list = list(df["value"].apply(lambda x: round(x, 4))) # + [round(other, 4)]
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