#!/usr/bin/env python

import pandas as pd
import sys

sarscov2_taxonomy = ["root","Viruses","Riboviria","Orthornavirae","Pisuviricota","Pisoniviricetes","Nidovirales","Cornidovirineae",
                     "Coronaviridae","Orthocoronavirinae","Betacoronavirus","Sarbecovirus","Severe acute respiratory syndrome-related coronavirus"]

def main():
    df = pd.read_csv(sys.argv[1], sep="\t", header=None, names=["percent", "num_related", "num_this_taxon","rank","taxid","taxonomy"], skipinitialspace=True)
    # df_sarscov2 = df[df["taxonomy"].isin(sarscov2_taxonomy)]
    # print(df_sarscov2)

    # remove sarscov2 count from higher taxa and any now-empty taxa from df
    sarscov2_count = df.loc[df["taxid"] == 2697049, "num_related"].squeeze()
    to_drop = ["Severe acute respiratory syndrome coronavirus 2","unclassified"]
    for taxon in sarscov2_taxonomy:
        df.loc[df["taxonomy"] == taxon, "num_related"] = df.loc[df["taxonomy"] == taxon, "num_related"] - sarscov2_count
        if df.loc[df["taxonomy"] == taxon, "num_related"].squeeze() == 0:
            to_drop.append(taxon)
    df = df[~df["taxonomy"].isin(to_drop)]

    # recalculate percents
    total = df.loc[df["taxonomy"].isin(["root"]), "num_related"].sum()
    # total = df.loc[df["taxonomy"].isin(["unclassified","root"]), "num_related"].sum()
    df["percent"] = df["num_related"] / total * 100
    df_sarscov2 = df[df["taxonomy"].isin(sarscov2_taxonomy)]
    print(df_sarscov2)
    # print(sarscov2_count)

    # df_classified = df[~df["taxonomy"].isin(["unclassified","root"] + sarscov2_upper_taxonomy + sarscov2_lower_taxonomy)]
    # print(df_classified["num_related"].sum())
    # count = None
    # for tax in sarscov2_upper_taxonomy[::-1]:
    #     print(tax)
    # df = df[df["taxonomy"] != "SARS-CoV-2"]
    df.to_csv(sys.argv[2], sep="\t", index=False)

if __name__ == "__main__":
    main()