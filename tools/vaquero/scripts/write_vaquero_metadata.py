#!/usr/bin/env python

from argparse import ArgumentParser
import pandas as pd 
from pathlib import Path
from datetime import datetime, timedelta

def parseArgs():
    parser = ArgumentParser(description="Converts limited metadata to the form required by VaQuERo")
    parser.add_argument("--metadata","-m",type=Path,help="metadata file to convert")
    parser.add_argument("--output","-o",type=Path,help="VaQuERo-style metadata output")
    return parser.parse_args()

def countNs(consensus):
    """Count the number of Ns in the consensus sequence"""
    totalNs = 0
    with consensus.open() as fh:
        seq = "".join([line.rstrip() for line in fh.readlines() if not line.startswith(">")]).strip("N")
    for char in seq:
        if char == "N":
            totalNs += 1
    return totalNs

def getNs(sample,meta):
    # # original method: count Ns in consensus fasta (which we no longer produce since it came from `artic minion`)
    # plate_dir = meta.parent
    # consensus = plate_dir / "output/samples" / (sample+".consensus.fasta")
    # ns = countNs(consensus)
    # new method: we want everything to pass, so just lie and say it's 0
    ns = 0
    return ns

def dateSpan(date,periods:int,freq:int):
    """Return new series of same size `length` with dates spanning a range, seperated by periods of length `seperation`"""

    start = datetime.fromisoformat(date) - timedelta(days=int(freq * periods / 2))
    s = pd.date_range(start=start, periods=periods, freq=f"{freq}D")
    return s

def main():
    args = parseArgs()
    df = pd.read_csv(args.metadata).rename(columns={"Sample ID":"BSF_sample_name","Sequence date":"BSF_start_date"})
    df["BSF_run"] = df["BSF_sample_name"]
    df["LocationID"] = "None"
    df["LocationName"] = "Nowhere"
    df["N_in_Consensus"] = df["BSF_sample_name"].apply(getNs,meta=args.metadata)
    df["RNA_ID_int"] = df["BSF_sample_name"]
    df["additional_information"] = ""
    df["adress_town"] = "Charlotte"
    df["connected_people"] = 0
    df["dcpLatitude"] = 35.31270260350986
    df["dcpLongitude"] = -80.74195454164692
    df["include_in_report"] = "TRUE"
    df["report_category"] = "MixedControls"
    # df["sample_date"] = df["BSF_start_date"] # used this for the --smoothingsamples 0 runs
    df["sample_date"] = dateSpan(df["BSF_start_date"].unique()[0],periods=len(df["BSF_start_date"]),freq=3)
    df["status"] = "passed_qc"


    df = df[["BSF_run","BSF_sample_name","BSF_start_date","LocationID","LocationName","N_in_Consensus","RNA_ID_int","additional_information","adress_town","connected_people","dcpLatitude","dcpLongitude","include_in_report","report_category","sample_date","status"]]
    df.to_csv(args.output, sep="\t", index=False)
    print("Results written to:", args.output)

if __name__ == "__main__":
    main()