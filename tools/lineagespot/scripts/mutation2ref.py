from argparse import ArgumentParser
from pathlib import Path
import pandas as pd

def parserArgs():
    parser = ArgumentParser(description="Convert mutation file (output by writing R-outbreak-info's getMutationsByLineage as csv) to the tsv format used by lineagespot.")
    parser.add_argument("-f", "--file", type=Path, help="Path to mutation file")
    parser.add_argument("-m", "--min_prevalence", default=0.8, type=float, help="Minimum prevalence value to include mutation. Defaults to 0.8.")
    parser.add_argument("-r", "--ref_dir", type=Path, help="Path to output directory (R ref directory used by lineagespot)")
    return parser.parse_args()

def getMutationDf(args):
    df = pd.read_csv(args.file)
    df = df[["mutation","lineage","prevalence"]]
    df = df[df["prevalence"]>=0.8]
    df[["gene","amino acid"]] = df["mutation"].str.split(":", expand=True)
    df["gene"] = df["gene"].str.upper()
    return df[["gene","amino acid","lineage"]]

def getRefDfs(df):
    for variant in df["lineage"].unique():
        vdf = df[df["lineage"]==variant][["gene","amino acid"]]
        yield vdf, variant

def main():
    args = parserArgs()
    for ref_df, variant in getRefDfs(getMutationDf(args)):
        ref_file = args.ref_dir/f"{variant}.txt"
        print("Writing out",ref_file)
        ref_df.to_csv(ref_file, index=False, sep="\t")

if __name__ == "__main__":
    main()