import argparse
import datetime as dt
import subprocess
import json
import sys

def main():
    parser = argparse.ArgumentParser(description="Preprocess reference collection: randomly select samples and write into individual metadata file in lineage-specific directories.")
    # parser.add_argument('-m, --metadata', dest='metadata', type=str, required=True, help="metadata tsv file for full sequence database")
    parser.add_argument('-f, --fasta', dest='fasta_in', type=str, required=True, help="fasta file representing full sequence database")
    # parser.add_argument('-i, --index', dest='fasta_index', type=str, required=True, help="fasta index file")
    # parser.add_argument('-k', dest='select_k', type=int, default=1000, help="randomly select 1000 sequences per lineage")
    # parser.add_argument('--max_N_content', type=float, default=0.001, help="remove genomes with N rate exceeding this threshold")
    # parser.add_argument('--min_seq_len', type=int, default=25000, help="remove genomes shorter than this threshold")
    # parser.add_argument('--min_seqs_per_lin', type=int, default=1, help="skip lineages with fewer sequences in the input fasta")
    # parser.add_argument('--continent', dest='continent', type=str, help="only consider sequences found in specified continent")
    # parser.add_argument('--country', dest='country', type=str, help="only consider sequences found in specified country")
    # parser.add_argument('--state', dest='state', type=str, help="only consider sequences found in specified state")
    # parser.add_argument('--startdate', dest='startdate', type=dt.date.fromisoformat, help="only consider sequences found on or after this date; input should be ISO format")
    # parser.add_argument('--enddate', dest='enddate', type=dt.date.fromisoformat, help="only consider sequences found on or before this date; input should be ISO format")
    # parser.add_argument('--seed', dest='seed', default=0, type=int, help="random seed for sequence selection")
    parser.add_argument('-o, --outdir', dest='outdir', type=str, default="seqs_per_lineage", help="output directory")
    parser.add_argument('--verbose', action='store_true')
    # parser.add_argument('--test_sed', action='store_true')
    args = parser.parse_args()

    with open(f"{args.outdir}/selection_dict.json") as fh:
        selection_dict = json.loads(fh.read())

    print("{} sequences selected".format(len(selection_dict.keys())))
    # write sequences to separate files
    print("searching fasta and writing sequences to output directory...")
    args.test_sed = False
    args.fasta_index = ""
    if args.test_sed:
        fasta_index = read_index(args.fasta_index)
        for seq_id, info in selection_dict.items():
            (lin_id, gisaid_id) = info
            outfile = "{}/{}/{}.fa".format(args.outdir, lin_id, gisaid_id)
            [start_idx, end_idx] = fasta_index[seq_id]
            subprocess.check_call("sed -n '{},{}p;{}q' {} > {}".format(
                    start_idx, end_idx, end_idx+1, args.fasta_in, outfile),
                    shell=True)
    else:
        with open(args.fasta_in, 'r') as f_in:
            keep_line = False
            line_idx = 0
            selection_idx = 0
            for line in f_in:
                if line[0] == '>':
                    # new record starts here
                    # first store previous record
                    if keep_line:
                        outfile = "{}/{}/{}.fa".format(args.outdir, lin_id, gisaid_id)
                        with open(outfile, 'w') as f_out:
                            f_out.write(">{}\n{}\n".format(seq_id, seq))
                    # now parse new record identifier
                    line_idx += 1
                    if args.verbose and line_idx % 100000 == 0:
                        print("{} sequences from input fasta processed".format(line_idx))
                        print("{} sequences from selection found".format(selection_idx))
                    seq_id = line.rstrip('\n').lstrip('>').split('|')[0]
                    # seq_id = line.rstrip('\n').lstrip('>').split()[0]
                    lin_id, gisaid_id = selection_dict.get(seq_id,(None,None))
                    try:
                        if not lin_id and not gisaid_id:
                            seq_id = seq_id.replace("_"," ")
                            lin_id, gisaid_id = selection_dict[seq_id]
                        seq = ""
                        keep_line = True
                        selection_idx += 1
                        # now remove key from dict to avoid writing duplicates
                        del selection_dict[seq_id]
                    except KeyError as e:
                        # item not found as sequence was not selected
                        print(f"Sample {seq_id} is not in selection_dict")
                        keep_line = False
                elif keep_line:
                    # append nucleotide sequence
                    seq += line.rstrip('\n')
            # add final record if necessary
            if keep_line:
                outfile = "{}/{}/{}.fa".format(args.outdir, lin_id, gisaid_id)
                with open(outfile, 'w') as f_out:
                    f_out.write(">{}\n{}\n".format(seq_id, seq))
            print("{} sequences from input fasta processed".format(line_idx))
            print("{} sequences from selection found".format(selection_idx))
        
    print(f"Remaining sample in selection_dict: {selection_dict}")

    return


def read_index(index_tsv):
    """Read fasta sequence index from file"""
    print("Reading fasta sequence index from file {}".format(index_tsv))
    index = {}
    with open(index_tsv, 'r') as f:
        for line in f:
            [seq_id, start_idx, end_idx] = line.rstrip('\n').split('\t')
            seq_id = seq_id.split('|')[0]
            index[seq_id] = [int(start_idx), int(end_idx)]
    return index


if __name__ == "__main__":
    sys.exit(main())
