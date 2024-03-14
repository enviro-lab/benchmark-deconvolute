#!/usr/bin/env python

from argparse import ArgumentParser
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

parser = ArgumentParser(description='Verifies that the input yml file has a section onder "calling-definition" called "probable". If not present, it will be added, using the values from "confirmed".')
parser.add_argument("yaml")
args = parser.parse_args()


with open(args.yaml) as fh:
    file = fh.read()

yam = load(file,Loader)

prob = yam["calling-definition"].get("probable")

if not prob:
    confirmed = yam["calling-definition"]["confirmed"]
    with open(args.yaml,'w') as out:
        confirmed_section = False
        confirmed_text = []
        for line in file.split("\n"):
            l = line.lstrip()
            if l.startswith("confirmed"):
                confirmed_section = True
            if l.startswith("low-qc"):
                # print("\n".join(confirmed_text).replace("confirmed","probable"))
                out.write("\n".join(confirmed_text).replace("confirmed","probable")+"\n")
                confirmed_section = False
                confirmed_text = []
            if confirmed_section == True:
                confirmed_text.append(line)
            out_line = line
            # print(out_line,end="")
            out.write(out_line+"\n")