#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd
from pathlib import Path
from freyja_plot.freyja_plot import get_lineage_summary


def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Converts LSV decompose/*.out TSV to freyja-like format")
    parser.add_argument("--tsv","-t",dest="file_dir",type=Path,help="Path to kallisto/bracken csv dir")
    parser.add_argument("--outfile","-o",type=Path,help="Path to use for freyja aggregate style output tsv")
    return parser.parse_args()

renames = {
"wt":"B",
"Alpha":"B.1.1.7",
"Beta":"B.1.351",
"Gamma":"P.1",
"Eta":"B.1.525",
"Epsilon":"B.1.427", # should also include "B.1.429"
"Delta":"B.1.617.2",
"Iota":"B.1.526",
"Kappa":"B.1.617.1",
}

def getPredictionDfs(file_dir):
    """Yields dataframes with a single sample from (`file_dir`) sorted descending by proportion"""

    names = ["variant","percent"]
    for file in file_dir.glob("*kallisto.out"):
        sample = file.name.split("_kallisto")[0]
        df = pd.read_csv(file, sep="\t",header=None, names=names)
        df["variant"] = df["variant"].apply(lambda x: renames.get(x,x))
        df["sample"] = sample
        df["variant"] = df["variant"].str.strip()
        df["proportion"] = df["percent"] / 100
        df = df.sort_values("proportion", ascending=False)
        # df["variant"] = df["variant_group"].str.split("_")[-1]
        # df = df[df["proportion"]>0.0001]
        other = 1 - df["proportion"].sum()
        if other < 0: other = 0
        yield sample, df, other


def writeLineageAbundanceFile(outfile, file_dir):
    """Converts `file_dir` to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for sample, df, other in getPredictionDfs(file_dir):

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
    writeLineageAbundanceFile(args.outfile, args.file_dir)
    print("Predictions written to:",args.outfile)
    return


if __name__ == "__main__":
    main()