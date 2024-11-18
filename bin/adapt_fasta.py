#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 

from Bio import SeqIO
from Bio.Seq import Seq

def read_fasta(path): 
    return SeqIO.parse(path, "fasta")
       
def write_fasta(path, sequences):
    with open(path, "w") as output_handle:
        SeqIO.write(sequences, output_handle, "fasta")

def main(): 
    import argparse
    parser = argparse.ArgumentParser(description="Adapter for fasta files")
    parser.add_argument("input", type=str, help="Path to subset containing all proteins")
    parser.add_argument("output", type=str, help="Output file")
    args = parser.parse_args()

    seqs = read_fasta(args.input)
    # # Remove * at the end of the sequences
    adapted_seqs = []
    for seq_entry in seqs:
        seq_entry.seq = Seq(str(seq_entry.seq).rstrip("*"))
        adapted_seqs.append(seq_entry)
    write_fasta(args.output, adapted_seqs)

if __name__ == "__main__":
    main()

