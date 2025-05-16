import sys

name_sequence_file = sys.argv[1] # Test: /local_scratch/rack/playground/workflow_test/corynebacteria_run/mmseqs2_results/clusterRes_rep_seq.fasta
name_topology_file = sys.argv[2] # Test: /local_scratch/rack/playground/Signalp_test/Signalp_results/prediction_results.txt
include_filter = sys.argv[3] # Test: LIPO
exclude_filter = sys.argv[4] # Test: TestTest

# read in list of proteins, if the protein sequence spans multiple lines we write everything in one line.
protein_seq_list = []
with open(name_sequence_file, "r") as file:
    list_entry = ""
    for line in file:
        if (">" in line):
            protein_seq_list.append(list_entry)
            list_entry = line.strip()
            protein_seq_list.append(list_entry)
            list_entry = ""
        else:
            list_entry = list_entry + line.strip()
    protein_seq_list.append(list_entry)

# read in the topologies from the txt
topology_data = []
with open(name_topology_file, "r") as file:
    for line in file:
        entry = line.split("\t")
        topology_data.append(entry[0:2])
topology_data = topology_data[2:]

# assemble the subset of interest based on the proteins topology, eg: LIPO
protein_subset = []
for entry in topology_data:
    if (include_filter in entry[1]) and (entry[1] != exclude_filter):
        protein_subset.append(entry)

#get the sequences from the subset
return_list = []
for i in protein_subset:
    for j in protein_seq_list:
        if i[0] in j:
            id_index = protein_seq_list.index(j)
            seq_index = id_index + 1
            return_list.append(protein_seq_list[id_index])
            return_list.append(protein_seq_list[seq_index])
    
# write the protein subset to a new file
with open("filtered_cluster_reps_signalP.fasta", "w") as outfile:
    for line in return_list:
        outfile.write(line + "\n")

# testing
print("number of proteins sequences")
print(len(protein_seq_list))
print(topology_data[0:10])
print("length of subset")
print(len(protein_subset))
print(protein_subset[0:10])
print("return list length")
print(len(return_list))
print(return_list[0:4])