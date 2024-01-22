#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd
from pathlib import Path
from freyja_plot.freyja_plot import get_lineage_summary


def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Converts LSV decompose/*.out TSV to freyja-like format")
    parser.add_argument("--tsv","-t",dest="kraken_dir",type=Path,help="Path to kallisto/bracken csv dir")
    parser.add_argument("--outfile","-o",type=Path,help="Path to use for freyja aggregate style output tsv")
    return parser.parse_args()


def getPredictionDfs(kraken_dir):
    """Yields dataframes with a single sample from (`kraken_dir`) sorted descending by proportion"""

    names = ["percent","x","y","taxa_type","z","variant"]
    for file in kraken_dir.glob("*majorCovid_bracken.out"):
        sample = file.name.split("_k2")[0]
        df = pd.read_csv(file, sep="\t",header=None, names=names)
        df = df[df["taxa_type"]=="C"]
        df["sample"] = sample
        df["variant"] = df["variant"].str.strip()
        df["proportion"] = df["percent"] / 100
        df = df.sort_values("proportion", ascending=False)
        # df["variant"] = df["variant_group"].str.split("_")[-1]
        # df = df[df["proportion"]>0.0001]
        other = 1 - df["proportion"].sum()
        if other < 0: other = 0
        yield sample, df, other


def writeLineageAbundanceFile(outfile, kraken_dir):
    """Converts `kraken_dir` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for sample, df, other in getPredictionDfs(kraken_dir):

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
    writeLineageAbundanceFile(args.outfile, args.kraken_dir)
    print("Predictions written to:",args.outfile)
    return


if __name__ == "__main__":
    main()