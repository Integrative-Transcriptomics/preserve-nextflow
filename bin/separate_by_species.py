#!/local_scratch/wittepaz/mamba/envs/CMFI/bin/python3 

from Bio import SeqIO

def read_from_id_to_sample(path):
    """
    Read a file containing id to sample name allocation
    :param path: path to the file
    :return: dictionary
    """
    from_id_to_sample = {}
    header = True
    with open(path, "r") as f: 
        for line in f: 
            # skip header
            if header:
                header = False
                continue
            splitted_lines = line.strip().split(",")

            from_id_to_sample[splitted_lines[1]] = {
                "sample" : splitted_lines[2],
                "organism": splitted_lines[4].strip()
            }
    return from_id_to_sample

def main(): 
    import argparse
    parser = argparse.ArgumentParser(description="Extract proteins from fasta file and divide by species")
    parser.add_argument("--fasta-in", type=str, help="Path to subset containing all proteins")
    parser.add_argument("--metadata", type=str, help="File containing id to sample name allocation")
    parser.add_argument("--output", type=str, help="Output file")
    args = parser.parse_args()

    parsed_fasta = SeqIO.to_dict(SeqIO.parse(args.fasta_in, "fasta"))

    from_id_to_sample = read_from_id_to_sample(args.metadata)

    dict_for_species = {}
    for key, value in parsed_fasta.items():
        sample_id = key.split("_")[2]
        species = from_id_to_sample[sample_id]["organism"]
        if species in dict_for_species:
            dict_for_species[species].append(value)
        else:
            dict_for_species[species] = [value]

    for species, records in dict_for_species.items():
        print(records[0])
        species = species.replace(" ", "_")
        # remove spaces from description of records
        for record in records:
            record.id = record.description.replace(" ", "_")
            record.description = ""
        SeqIO.write(records, f"{args.output}_{species}.fasta", "fasta")

if __name__ == "__main__":
    main()

