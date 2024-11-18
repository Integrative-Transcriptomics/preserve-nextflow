#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 

import argparse
import random
import os
from Bio import SeqIO

def read_relevant_genes(path, subset=None, operons=None):
    """
    Given a path, extract all genes found within the file and return a list of genes
    """
    genes = []
    with open(path, 'r') as f:
        for line in f:
            line = line.strip().split("\t")
            gene = line[0].replace('.r01', '')
            genes.append(gene)

    if subset:
        genes_operons = set([operons[x] for x in genes if x in operons.keys()])
        # Return random subset of genes
        genes = random.sample(genes_operons, subset)
    return genes

def group_genes_via_prefix(genes):
    """
    Given a list of genes, group them by their prefix
    """
    gene_groups = {}
    for gene in genes:
        prefix = gene.split("_")[0]
        if prefix not in gene_groups:
            gene_groups[prefix] = []
        gene_groups[prefix].append(gene)
    return gene_groups

def from_gene_prefix_to_sample(grouped_genes, id_to_sample):
    """
    Given a dictionary of grouped genes and a dictionary of id to sample, return a dictionary of gene to sample
    """
    gene_to_sample_info = {}
    for prefix, genes in grouped_genes.items():
        sample = id_to_sample[prefix]["sample"]
        fasta = id_to_sample[prefix]["fasta"]
        gff = id_to_sample[prefix]["gff"]
        gene_to_sample_info[prefix] ={
            "sample": sample,
            "genes": genes,
            "fasta": fasta,
            "gff": gff
        }
    return gene_to_sample_info

def read_id_to_sample(path, fasta_dir, gff_dir):
    id_to_sample = {}
    # Get all files in fasta ending with .fna, .fa or .fasta
    fasta_files = [f for f in os.listdir(fasta_dir) if f.endswith(".fna") or f.endswith(".fa") or f.endswith(".fasta")]
    # Get all files in gff ending with .gff
    gff_files = [f for f in os.listdir(gff_dir) if f.endswith(".gff") or f.endswith(".gff3")]
    with open(path, 'r') as file:
        for line in file:
            elements = line.strip().split()
            sample = elements[1].strip()
            gene_prefix = elements[0]
            print(f"gene_prefix: {gene_prefix}")
            print(f"sample: {sample}")
            print(f"fasta_dir: {fasta_files}")
            fasta = f"{fasta_dir}/{[f for f in fasta_files if f"{sample}." in f][0]}"
            gff = f"{gff_dir}/{[f for f in gff_files if f"{sample}." in f][0]}"
            id_to_sample[gene_prefix] = {"sample": sample.strip(),
                                         "fasta": fasta, "gff": gff}
    return id_to_sample

def read_gene_list_and_tss(path):
    """
    Given a path, read a four-column file with the following format:
    contig   GENE_ID    STRAND    TSS_POSITION
    and return a dictionary with the following format:
    {
        "GENE_ID": {
            "contig": contig,
            "strand": strand,
            "tss": tss_position
        }
    }
    """
    gene_list = {}
    with open(path, 'r') as f:
        for line in f:
            line = line.strip().split("\t")
            if line[3] != "NA":
                gene_list[line[1]] = {"contig": line[0],
                                      "strand": line[2], "tss": int(line[3])}
    return gene_list


def read_genome(path):
    """
    Given a path, read a fasta file and return a dictionary with the following format:
    {
        "contig": sequence
    }
    """
    genome = SeqIO.to_dict(SeqIO.parse(path, "fasta"))
    # genome = {}
    # with open(path, 'r') as f:
    #     for line in f:
    #         if line.startswith(">"):
    #             contig = line.strip().split(">")[1]
    #             contig_info = contig.split(" ")[0]
    #             genome[contig_info] = ""
    #         else:
    #             genome[contig_info] += line.strip()
    return genome


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
            if '##FASTA' in line:
                break
            if line.startswith('#'):
                continue
            line = line.strip().split('\t')
            if len(line) < 9:
                continue
            if line[2] == 'gene':
                contig = line[0]
                start = int(line[3])
                end = int(line[4])
                strand = line[6]
                gene_information = list(
                    map(lambda x: x.split("="), line[8].split(';')))
                gene_information = {x[0]: x[1] for x in gene_information}
                locus_tag = gene_information['ID']
                gff[locus_tag] = {"contig": contig, "start": start, "end": end,
                                  "strand": strand, "gene_information": gene_information}
    return gff


def read_operon_mapper(path_operon):
    """
    read three column file, structured as following: 
    gene    leading_gene of operon    operon_members
    and return a gene-> leading_gene mapper
    """
    operon_mapper = {}
    with open(path_operon, 'r') as f:
        for line in f:
            line = line.strip().split("\t")
            operon_mapper[line[0]] = line[1]
    return operon_mapper


def reverse_complement(sequence):
    """
    Given a DNA sequence, return the reverse complement
    """
    complement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    return ''.join([complement[base] for base in sequence[::-1]])

def transfrom_genes_to_operon_starts(genes, operons):
    """
    Given a list of genes and a operon mapper, return a list of operons
    """
    operons = [operons[x] for x in genes]
    return operons

def extract_promoter_region(gff, genome, gene, distance, inGene):
    """
    Given a gff dictionary, a genome dictionary, a gene, a distance and a inGene, return the promoter region
    """
    start_gene = gene
    # add to accounted_operon_starts
    contig = gff[start_gene]["contig"]
    if gff[gene]["strand"] == "+":
        start_cord = gff[start_gene]["start"]   
        start_promoter = max(start_cord - distance, 0)
        end_promoter: int =  start_cord
        if inGene:
            end_promoter = min(
                start_cord + inGene, len(genome[contig]))
    else:
        start_cord = gff[start_gene]["end"]
        start_promoter = start_cord
        if inGene:
            start_promoter = max(start_cord - inGene, 0)
        end_promoter = min(
            start_cord + distance, len(genome[contig]))
    promoter = genome[contig].seq[start_promoter:end_promoter]
    if gff[gene]["strand"] == "-":
        promoter = reverse_complement(promoter)
    return promoter
def main():
    # Get arguments
    parser = argparse.ArgumentParser(
        description='Given a list of genes and a genome, extract the promoter region of the genes')
    parser.add_argument('--gene_list', '-g', type=str,
                        help='Path to gene list')
    parser.add_argument('--metadata', '-m', type=str, help='Path to metadata')
    parser.add_argument('--genome_dir', '-fastas', type=str, help='Path to genome directory')
    parser.add_argument('--gff_dir', '-gffs', type=str, help='Path to gff directory')
    parser.add_argument('--operon_list', '-op', type=str, help='Path to operon list')
    parser.add_argument('--distance', '-d', type=int,
                        default=50, help='Distance to extract promoter region')
    parser.add_argument('--inGene', '-i', type=int, default=0,
                        help='Distance to extract promoter region within CDS region')
    parser.add_argument('--output', '-o', type=str, help='Path to output file')

    args = parser.parse_args()
    gene_list = read_relevant_genes(args.gene_list)
    if args.operon_list:
        operons = read_operon_mapper(args.operon_list)
        gene_list = transfrom_genes_to_operon_starts(gene_list, operons)
        # remove duplicates of genes
        gene_list = list(set(gene_list))
    grouped_genes = group_genes_via_prefix(gene_list)
    from_prefix_to_sample = read_id_to_sample(args.metadata, args.genome_dir, args.gff_dir)
    from_prefix_to_sample_with_genes = from_gene_prefix_to_sample(grouped_genes, from_prefix_to_sample)
    with open(args.output, 'w') as f:
        for prefix, sample_info in from_prefix_to_sample_with_genes.items():
            genome = read_genome(sample_info["fasta"])
            gff = read_gff(sample_info["gff"])
            for gene in sample_info["genes"]:
                promoter = extract_promoter_region(gff, genome, gene, args.distance, args.inGene)
                f.write(f">{sample_info['sample']}_{gene}_promoter\n")
                f.write(f"{promoter}\n")


if __name__ == '__main__':
    main()
