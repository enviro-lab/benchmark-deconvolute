#!/usr/bin/env python

from argparse import ArgumentParser
from pathlib import Path
import pandas as pd
import sys

def parse_args():
    parser = ArgumentParser(description="Converts primer scheme bed file to amplicon bed file, showing start")
    parser.add_argument("scheme", type=Path, help="Primer scheme bed file to convert. The primer name is split on '_' to these columns: [label,pair_number,direction,alt].")
    parser.add_argument("-b","--bounds", default="inner", choices=["inner","outer"], help="If 'inner', amplicon bounds are set by the inner ends of the primers. 'outer' uses the outer ends.")
    parser.add_argument("-o","--output", type=Path, default=sys.stdout, help="Output amplicon bed file")
    return parser.parse_args()

def splitName(row):
    """Splits name into constituents by '_'"""

    name = row["name"]
    components = name.split("_")
    if len(components)<3:
        print("bad number of name components:",name,"->",components)
        exit(0)
    label,pair_num,direction = components[:3]
    pair_number = "_".join((label, pair_num))
    alt = components[3] if len(components) == 4 else ""
    # print(label,pair_number,direction,alt,"--")
    return label,pair_number,direction,alt

def readPrimerDf(fn):
    """Reads in primer scheme bed file"""

    df = pd.read_csv(fn,sep="\t",header=None,names=["chrom","start","end","name","num"],usecols=range(5))
    df[["label","pair_number","direction","alt"]] = df.apply(splitName,axis=1,result_type='expand')
    return df

def getAmplicons(scheme, bounds="inner"):
    if bounds == "inner":
        left_bound, right_bound = "end", "start"
    else: # outer
        left_bound, right_bound = "start", "end"
    for chrom in scheme["chrom"].unique():
        chrom_df = scheme[scheme["chrom"]==chrom]
        for pair_number in chrom_df["pair_number"].unique():
            primer_df = chrom_df[chrom_df["pair_number"]==pair_number].drop_duplicates()
            num = str(primer_df["num"].unique().squeeze()).split("_")[-1]
            pair_number = str(primer_df["pair_number"].unique().squeeze())
            
            lefts = primer_df[primer_df["direction"]=="LEFT"]
            # left = lefts[lefts["alt"].isna()]
            # other_lefts = lefts[lefts["alt"].notna()]

            rights = primer_df[primer_df["direction"]=="RIGHT"]
            # right = rights[rights["alt"].isna()]
            # other_rights = rights[rights["alt"].notna()]

            # print(type(lefts))
            # exit(1)
            for i,left in lefts.iterrows():
                for i,right in rights.iterrows():
                    yield pd.DataFrame({
                        "chrom":[chrom],
                        "left":[left[left_bound]],
                        "right":[right[right_bound]],
                        "pair_number":[pair_number],
                        "num":[num],
                        "orientation":["+"],
                        })

def scheme2amplicons(scheme, bounds="inner"):
    """Converts primer positions to amplicon positions"""

    ampliconDF = pd.concat((amp_df for amp_df in getAmplicons(scheme, bounds=bounds)))
    return ampliconDF

def schemeFile2AmpliconDf(bed, bounds="inner"):
    """Converts primer positions from bed file to amplicon positions"""

    scheme = readPrimerDf(bed)
    amplicon_df = scheme2amplicons(scheme, bounds=bounds)
    return amplicon_df


def main():

    args = parse_args()

    amplicons = schemeFile2AmpliconDf(args.scheme, bounds=args.bounds)

    amplicons.to_csv(args.output, index=False, sep="\t", header=False)

if __name__ == "__main__":
    main()