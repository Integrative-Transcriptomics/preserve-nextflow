#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 

import pandas as pd
import argparse
def read_gff(gff_file):
    gff_dict = {}
    with open(gff_file, 'r') as f:
        for line in f:
            if line.startswith('##FASTA'):
                break
            if line.startswith('#'):
                continue
            line = line.strip().split('\t')
            if line[2] == 'gene':
                gene_id = list(filter(lambda x: "ID" in x, line[8].split(';')))[0].split('=')[1].replace('.p01', '')

                gff_dict[gene_id] = {
                    "start": int(line[3]),
                    "end": int(line[4]),
                    "strand": line[6],
                }
    return gff_dict

def read_gff_as_df(gff_file):
    gff_df = pd.read_csv(gff_file, sep="\t", comment="#", header=None)
    gff_df = gff_df[gff_df[2] == "gene"]
    gff_df["locus_tag"] = gff_df[8].str.extract(r'ID=(\w+);')

    return gff_df

def main(): 
    # create argparse
    parser = argparse.ArgumentParser(description='Filter lipoproteins with close TMMs')
    parser.add_argument('lipoproteins', help='File containing lipoproteins found as homologs with Foldseek')
    parser.add_argument("tmm", help="File containing TMMs")
    parser.add_argument('gff_file', help='GFF file')
    
    # Add optional threshold
    parser.add_argument('--threshold', type=int, default=150, help='Threshold for distance between TMMs')
    parser.add_argument("--ignore-strand", action="store_true", help="Keep strand information")
    parser.add_argument('--output', type=str, help='Output file')
    lipoprotein_with_tmms = []
    args = parser.parse_args()
    lipoproteins = pd.read_csv(args.lipoproteins, sep="\t", header=None)
    list_lipo = list(map(lambda x: x.replace(".p01", ""), lipoproteins[0].tolist()))
    print(lipoproteins.head())
    tmm = set(pd.read_csv(args.tmm, sep="\t", header=None)[0].tolist())
    # basename of gff_file
    basename = args.gff_file.split("/")[-1].replace(".gff", "")
    gff = read_gff_as_df(args.gff_file)
    print(gff.head())
    gff_as_dict = read_gff(args.gff_file)
    # print(gff_as_dict)
    intersection_keys = set(gff_as_dict.keys()).intersection(set(list_lipo))
    for relevant_lipoprotein in intersection_keys:
        print(relevant_lipoprotein)
        data = gff_as_dict[relevant_lipoprotein]
        start = data["start"]
        end = data["end"]
        strand = data["strand"]
        mod_start = start - args.threshold
        mod_end = end + args.threshold
        filt_gff = gff[(gff[4] >= mod_start) & (gff[3] <= start) | (gff[3] <= mod_end) & (gff[4] >= end)]
        if not args.ignore_strand:
            filt_gff = filt_gff[filt_gff[6] == strand]
        close_genes_via_threshold = set(filt_gff["locus_tag"].tolist())
        close_to_tmm = len(close_genes_via_threshold.intersection(tmm)) > 0
        if close_to_tmm:
            lipoprotein_with_tmms.append(relevant_lipoprotein)
    with open(args.output+"/"+basename+".txt", 'w') as f:
        for lipo in lipoprotein_with_tmms:
            f.write(lipo + "\n")

if __name__ == "__main__":
    main()


