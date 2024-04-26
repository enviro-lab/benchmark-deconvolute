#!/usr/bin/env python

from argparse import ArgumentParser
from pathlib import Path
import pandas as pd

parser = ArgumentParser(description="Reads in vcf file and remove the worst of any duplicate positions.")
parser.add_argument("-f", "--vcf", type=Path, help="vcf file to convert")
parser.add_argument("-a", "--af_file", type=Path, help="tsv file (vcf headers) containing 'AF1' in INFO")
parser.add_argument("-o", "--out", type=Path, help="where to write output")
args = parser.parse_args()

if "gz" in args.vcf.suffix:
    import gzip
    _open = gzip.open
else: _open = open

def get_element(line, column, cols):
    attributes = line.strip().split("\t")
    return attributes[cols[column]]

def new_is_better(old_line,new_line,cols):
    old_qual = get_element(old_line,"QUAL", cols)
    new_qual = get_element(new_line,"QUAL", cols)
    return new_qual > old_qual

def get_allele_freq(tsv):
    """Returns df with allele frequency"""
    df = pd.read_csv(tsv,sep="\t")
    df["AF"] = df["INFO"].apply(lambda x: float([y for y in x.split(";") if y.startswith("AF1=")][0].split("=")[-1]))
    # df["DP"] = df["INFO"].apply(lambda x: float([y for y in x.split(";") if y.startswith("DP=")][0].split("=")[-1]))
    # df["DepthOfAllele"] = df.apply(lambda row: int(row["AF"] * row["DP"]), axis=1)
    # df["AD"] = df.apply(lambda row: f"{int(row['DP']-row['DepthOfAllele'])},{int(row['DepthOfAllele'])}", axis=1)
    # df = df.drop(columns=["AF","DP","DepthOfAllele"])
    # print(df["POS"],df["AF"])
    return {pos:freq for pos,freq in zip(df["POS"],df["AF"])}

def fixLine(line,ad_alt):
    """Renames chrom and adds AD to FORMAT & SAMPLE sections"""
    # reset chromosome name
    line = line.replace("MN908947.3","NC_045512.2")

    # add in AD details to FORMAT column
    components = line.split("\t")
    info = components[7]
    info_elements = info.split(";")
    dp = float([e for e in info_elements if e.startswith("DP=")][0].split("=")[1])
    # for e in info_elements:
    #     if e.startswith("DP="):
    #         ad = e.replace("DP=","AD=")

    # AD: ref-allele-depth, alt-allele-depth
    ad = f"{dp*(1-ad_alt)},{dp*ad_alt}"
    fmt = f"{components[8]}:AD"
    fmt_data = f"{components[9].rstrip()}:{ad}\n"
    line = "\t".join(
        components[:8] + [fmt] + [fmt_data]
    )
    return line

def main():
    lines_by_pos = {}
    with _open(args.vcf) as fh, open(args.out,'w') as out:
        for line in fh:
            line = str(line,encoding='utf-8')
            if line.startswith("#"):
                # map field names to column number
                if line.startswith("#CHROM"):
                    cols = {name:i for i,name in enumerate(line.strip().split("\t"))}
                # add AD FORMAT info in reasonable location
                elif line.startswith("##FORMAT=<ID=GQ,"):
                    out.write('##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">\n')
                out.write(line)
                continue

            # add line for each new position or (if already exists) update to best quality
            pos = get_element(line, "POS", cols)
            if not pos in lines_by_pos.keys():
                lines_by_pos[pos] = line
            else:
                old_line = lines_by_pos[pos]
                if new_is_better(old_line,line,cols):
                    lines_by_pos[pos] = line

        # read in allele frequencies from seperate file
        alt_allele_freqs = get_allele_freq(args.af_file)

        # add allele freq to each line and write out
        for pos,line in lines_by_pos.items():
            # default to an alt frequency of 1 if our af_tsv failed to detect a variant that artic called
            ad_alt = alt_allele_freqs.get(int(pos), 1)
            out.write(fixLine(line,ad_alt))

if __name__ == "__main__":
    main()