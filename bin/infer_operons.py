#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 

import argparse

def read_gff(gff_path):
    '''
    Read a gff file and return a dictionary with the following structure:
    {
        "locus_tag": {
            "start": start,
            "end": end,
            "strand": strand,
            "gene_information": {
                "locus_tag": locus_tag,
                "gene": gene,
                "product": product,
                ... and so on.
                }
    '''
    gff = {}
    with open(gff_path, 'r') as gff_file:
        for line in gff_file:
            if line.startswith('##FASTA'):
                break
            if line.startswith('#'):
                continue

            line = line.strip().split('\t')
            # print(line[2])
            if line[2] in ["CDS","tRNA","rRNA"]:
                contig = line[0]
                start = int(line[3])
                end = int(line[4])
                strand = line[6]
                gene_information = list(map(lambda x: x.split("="), line[8].split(';')))
                # print(gene_information)
                gene_information = {x[0]: x[1] for x in gene_information}
                locus_tag = gene_information['ID']
                gff[locus_tag] = {"contig": contig, "start": start, "end": end, "strand": strand, "gene_information": gene_information}
    return gff

def predict_operons(gff, distance_operons=100):
    """
        From the given GFF, return an operon list. 
        Each gene is part of the first column using their IDS. 
        The second column refers to the gene leading the operon (i.e. the first gene in the operon)
        The last column refers to all genes found in the operon. 
        Remember, operons are just found within the same strand of the gene. 
    """
    gff_by_contig = {}
    for gene, info in gff.items():
        contig = info['contig']
        if contig not in gff_by_contig:
            gff_by_contig[contig] = {}
        if info['strand'] not in gff_by_contig[contig]:
            gff_by_contig[contig][info['strand']] = []
        gff_by_contig[contig][info['strand']].append((gene, info['start'], info['end'], info["gene_information"]))
    operons = []
    for contig, strands in gff_by_contig.items():
        for  genes in strands.values():
            genes.sort(key=lambda x: x[1])
            operon = []
            for index, gene in enumerate(genes):
                if index == 0:
                    operon.append([gene[0], gene[0], gene[0]])
                else:
                    if gene[1] - genes[index-1][2] <= distance_operons:
                        operon[-1][2] = operon[-1][2] + ";" + gene[0]
                    else:
                        operon.append([gene[0], gene[0], gene[0]])
            operons.extend(operon)
    return operons


def main(): 
    # Get arguments
    parser = argparse.ArgumentParser(description="Given a gff file, a list of DE genes and a coverage file, find the TSS of the DE genes.")
    parser.add_argument("gff", help="Path to gff file")
    parser.add_argument("output", help="Path to operon file")
    #add distance for operons as argument
    parser.add_argument("--distance_operons", help="Distance between genes to be considered as part of the same operon", default=100)
    # Read gff file
    args = parser.parse_args()
    gff = read_gff(args.gff)
    operons = predict_operons(gff, int(args.distance_operons))
    operons.sort(key=lambda x: x[0])
    with open(args.output, 'w') as f:
        for operon in operons:
            for member_operon in operon[2].split(";"):
                f.write(f"{member_operon}\t{operon[1]}\t{operon[2]}\n")

if __name__ == "__main__":
    main()