#!/usr/bin/env python

#!/usr/bin/env python3

import sys
from pathlib import Path
import numpy as np
import pandas as pd
from argparse import ArgumentParser
from freyja_plot.freyja_plot import get_lineage_summary
from collections import defaultdict

def parseArgs():
    """Parses arguments"""

    parser = ArgumentParser(description="Writes out predicted alcov lineage abundances like freyja aggregated output")
    parser.add_argument("infile",type=Path,help="Input csv from alcov to convert to freyja-like aggregated output")
    parser.add_argument("-o",dest="outfile",type=Path,help="Output tsv filename.")
    return parser.parse_args()

def get_df(csv):
    df = pd.read_csv(csv)
    df = df.rename(columns={col:col.replace("-like", "") for col in df.columns})
    renames = {f"Mixture{x}":f"Mixture0{x}" for x in range(1,10)}
    df["Sample name"] = df["Sample name"].apply(lambda x: renames.get(x,x))
    df = df.set_index("Sample name")
    df = df.astype(float,errors="ignore")
    # number_cols = [col for col in df.columns if col != "Sample name"]
    # for col in number_cols:
    #     df[col] = df[col].astype(float)
    # df["sum"] = df.sum()
    df["Other"] = (np.ones(len(df)) - df.sum(axis=1)).clip(lower=0)
    df = df.reset_index()
    df = df.fillna(0)
    print(df)
    return df

def abundance_predictions(csv):
    """Yield sample_name, lineage_list, abundance_list for each sample"""
    df = get_df(csv)

    for i,row in df.iterrows():
        # one row has data for one sample
        sample_name = row["Sample name"]
        lineage_dict = defaultdict(int)
        for lineage in row.index[1:]:
            abundance = float(row[lineage])
            # let's ignore any lineages with 0 abundance
            if abundance == 0.0:
                continue
            if "or" in lineage:
                lineage_dict["Other"] += abundance
            else:
                lineage_dict[lineage] += abundance
    
        # sort lineages by highest abundance
        lineages,abundances = [],[]
        for lineage,abundance in sorted(lineage_dict.items(), key=lambda x: x[1], reverse=True):
            # print(type(lineages),type(lineage))
            lineages.append(lineage)
            # print(type(abundances),type(abundance))
            abundances.append(abundance)
        yield sample_name,lineages,abundances
            

def writeLineageAbundanceFile(outfile, csv):
    """Converts `csv` abundance predictions to freyja-style tsv `outfile`"""

    with outfile.open('w') as out:
        out.write("\tsummarized\tlineages\tabundances\tresid\tcoverage\n")

        for sample_name, lineage_list, abundance_list in abundance_predictions(csv):
            print(sample_name, sum(abundance_list))
            
            # df = df[df["adj_freq(%)"]>0.0]
            # sample_name = str(df["sample_name"].unique().squeeze())

            # lineage_list = list(df["variant"])
            lineages = " ".join(lineage_list)
            # print(df["adj_freq(%)"])
            # abundance_list = list(df["adj_freq(%)"].apply(lambda x: round(x/100, 4)))
            abundances = " ".join((str(x) for x in abundance_list))
            resid = ""
            coverage = ""

            summarized = get_lineage_summary(lineage_list, abundance_list)

            out.write(f"{sample_name}\t{summarized}\t{lineages}\t{abundances}\t{resid}\t{coverage}\n")


    
def main():
    """Compiles predictions data for analysis"""

    args = parseArgs()

    # write out frequencies like freyja output
    writeLineageAbundanceFile(args.outfile, args.infile)
    print("Predictions writen to:",args.outfile)

    return


if __name__ == '__main__':
    sys.exit(main())