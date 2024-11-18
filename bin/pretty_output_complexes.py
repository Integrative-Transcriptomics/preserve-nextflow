#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 
import argparse


def read_complexes(path, id_to_sample, lipoproteins, transmembrane): 
    sample_complexes = {}
    with open(path, 'r') as file: 
        complex_id = 0
        for line in file: 
            complexes = line.split(';')
            sample_id = complexes[0].split("_")[0]
            sample_name = id_to_sample[sample_id]
            if sample_name not in sample_complexes: 
                complex_id = 0
                sample_complexes[sample_name] = {}
            else:
                complex_id += 1
            complex_key = f"complex_{complex_id}"
            sample_complexes[sample_name][complex_key] = {}
            for element in complexes: 
                if element.strip() == '': 
                    continue
                if element.strip() in lipoproteins:
                    sample_complexes[sample_name][complex_key][element.strip()] = 'lipoprotein'
                elif element.strip() in transmembrane:
                    sample_complexes[sample_name][complex_key][element.strip()] = 'transmembrane'
                else:
                    sample_complexes[sample_name][complex_key][element.strip()] = 'other'
    return sample_complexes


def read_list_genes(path): 
    genes = []
    with open(path, 'r') as file: 
        for line in file: 
            genes.append(line.strip())
    return genes

def read_id_to_sample(path): 
    id_to_sample = {}
    with open(path, 'r') as file: 
        for line in file: 
            elements = line.strip().split()
            print(elements)
            id_to_sample[elements[0]] = elements[1].strip()
    return id_to_sample
def write_complexes(sample_complexes, path):
    with open(path, 'w') as file: 
        file.write("Sample\tComplex\tGene\tType\n")
        for sample in sample_complexes: 
            for complex in sample_complexes[sample]: 
                for gene in sample_complexes[sample][complex]: 
                    file.write(f"{sample}\t{complex}\t{gene}\t{sample_complexes[sample][complex][gene]}\n")

def main(): 

    # create argparse
    parser = argparse.ArgumentParser(description="Given all possible genes found in an operon, create a pretty output.")
    parser.add_argument('geneID_toSamples', help='File containing geneID to sample information')
    parser.add_argument('lipoproteins', help='File containing lipoproteins found in complexes')
    parser.add_argument('transmembrane', help='File containing transmembrane proteins found in complexes')
    parser.add_argument('complexes', help='File containing all complexes')
    parser.add_argument('output', help='Output file')
    args = parser.parse_args()
    id_to_sample = read_id_to_sample(args.geneID_toSamples)
    lipoproteins = read_list_genes(args.lipoproteins)
    transmembrane = read_list_genes(args.transmembrane)
    sample_complexes = read_complexes(args.complexes, id_to_sample, lipoproteins, transmembrane)
    write_complexes(sample_complexes, args.output)

if __name__ == '__main__': 
    main()