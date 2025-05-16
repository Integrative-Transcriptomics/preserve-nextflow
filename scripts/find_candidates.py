# Read the .Json output of fasta and determine which proteins have a >0.95 Identity with a protein from a database (Uniprot)
import json
import sys

# Arguments: 
# 1) list of all proteins to check in fasta format
# 2) the name for the output file with the proteins that have uniprot references (.tsv)
# 3) the name for the output file with the rejected proteins (.fasta) because we need the sequence to predict structure
# 4+ the different jsons containing the database cross-references, one per initial genome
fasta_file_name = sys.argv[1] # Test: /local_scratch/rack/playground/workflow_test/filter_results/filtered_cluster_reps.fasta
output_name_tsv = sys.argv[2] # Test: proteins_with_ref.tsv
output_name_fasta = sys.argv[3] # Test: proteins_without_ref.fasta
similarity_threshold = sys.argv[4] # Test: 0.95
json_file_names = sys.argv[5:] # Test: /local_scratch/rack/playground/bakta_test/bakta_results/Nichols-Houston.fasta_out/Nichols-Houston.fasta.json
                                # Test: /local_scratch/rack/playground/bakta_test/bakta_results/Haiti-B.fasta_out/Haiti-B.fasta.json


jsons = []
for name in json_file_names:
    with open(name, 'r') as file:
        data1 = json.load(file)
        jsons.append(data1)

# get the list of proteins from the fasta file
fasta_list = []
with open(fasta_file_name) as file:
    for line in file:
        fasta_list.append(line.strip())

# select only the protein ID from the line
protein_list = []
for i in fasta_list:
    if (fasta_list.index(i) % 2 == 0):
        protein_list.append(i[1:13])

print(len(jsons))
print("All proteins length")
print(len(protein_list))

# Extract a list of proteins that have a good Uniprot database reference (more than 0.95 similarity)
protein_references = []
for json in jsons:
    for feature in json["features"]:
        if ("locus" in feature) and ("pscc" in feature):
            if (feature["pscc"]["identity"] > similarity_threshold):
                entry = []
                entry.append(feature["locus"])
                if "uniref50_id" in feature["pscc"]:
                    entry.append(feature["pscc"]["uniref50_id"])
                if "uniref90_id" in feature["pscc"]:
                    entry.append(feature["pscc"]["uniref90_id"])
                if "uniref100_id" in feature["pscc"]:
                    entry.append(feature["pscc"]["uniref100_id"])
                entry.append(feature["pscc"]["identity"])
                protein_references.append(entry)
                
        
#print(protein_references)

# Divide the proteins into ones with db ref and ones without
proteins_with_reference = []
for i in protein_references:
    if (i[0] in protein_list) and (len(i[1]) < 16):
        proteins_with_reference.append(i)

print("PROTEINS WITH REFERENCE:")
print(len(proteins_with_reference))
#print(proteins_with_reference)
#print("ALL PROTEINS:")
#print(protein_list)
#print(proteins_with_reference)

proteins_without_ref = []
for i in protein_list:
    has_ref = False
    for entry in proteins_with_reference:
        if i in entry[0]:
            has_ref = True
    if has_ref is False:
        proteins_without_ref.append(i)

print("Proteins without Reference:")
print(len(proteins_without_ref))
    
# Make a file with the proteins with reference (column 1), the ref (column 2) and the similarity (column 3)    
with open(output_name_tsv, "w") as outfile:
    outfile.write("Protein\tReference\tIdentity\n")
    for entries in proteins_with_reference:
        outfile.write(entries[0]+"\t"+entries[1]+"\t"+str(entries[2])+"\n")

# Make a fasta that contains the proteins without ref
with open(output_name_fasta, "w") as outfile:
    for protein in proteins_without_ref:
        for i in fasta_list:
            if protein in i:
                current_protein_line = fasta_list.index(i)
                outfile.write(i+"\n")
                outfile.write(fasta_list[current_protein_line+1]+"\n")

