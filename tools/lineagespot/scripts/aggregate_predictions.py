#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd
from pathlib import Path
from freyja_plot.freyja_plot import get_lineage_summary


def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Converts lineagespot TSV to freyja-like format")
    parser.add_argument("--tsv","-f",dest="prediction_file",type=Path,help="Path to lineagespot deconv tsv output")
    parser.add_argument("--outfile","-o",type=Path,help="Path to use for freyja aggregate style output tsv")
    return parser.parse_args()


def getPredictionDfs(prediction_file):
    """Yields dataframes with a single sample from (`prediction_file`) sorted descending by proportion"""

    df = pd.read_csv(prediction_file, sep=",", usecols=[0,1,7])
    df = df.rename(columns={"lineage prop.":"proportion", "lineage":"variant"})
    df["variant"] = df["variant"].str.replace("B.1.1.7+S_E484K","B.1.1.7")
    df = df.groupby(["sample","variant"]).agg({"proportion":"sum"}).reset_index()
    df = df[df["variant"]!="undetermined"]

    samples = [f"Mixture{x:02}" for x in range(1,43)] + ["NFWA","NFWC"]
    
    for sample in samples:
        sdf:pd.DataFrame = df[df["sample"]==sample]
        if sdf.empty:
            other = 1
        else:
            sdf = sdf.sort_values("proportion", ascending=False)
            sdf["proportion"] = sdf["proportion"].astype(float)
            sdf = sdf[sdf["proportion"]>0.0001]
            other = 1 - sdf["proportion"].sum()
        yield sample, sdf, other


def writeLineageAbundanceFile(outfile, prediction_file):
    """Converts `prediction_file` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        # write header line
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        # add details for each sample
        for sample, df, other in getPredictionDfs(prediction_file):
            print(sample)

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