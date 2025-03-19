# Read file names from the Command line arguments, the list of representatives has to be parsed first, the topologies second.
# The third argument is a string which the filtered line must include, and the fourth is a string to exclude.
import sys
name_sequence_file = sys.argv[1] # Test: /local_scratch/rack/playground/workflow_test/deepTMHMM_results/clusterRes_rep_seq.fasta
name_topology_file = sys.argv[2] # Test: /local_scratch/rack/playground/workflow_test/deepTMHMM_results/biolib_results/predicted_topologies.3line
include_filter = sys.argv[3] # Test: TM
exclude_filter = sys.argv[4] # Test: SP

# read in list of proteins
protein_seq_list = []
with open(name_sequence_file, "r") as file:
    for line in file:
        protein_seq_list.append(line.strip())

# read in list of proteins with topologies
protein_top_list = []
with open(name_topology_file, "r") as file:
    for line in file:
        protein_top_list.append(line.strip())

# filter the list by topology to get the subset of proteins we are interested in
protein_subset = []
for line in protein_top_list:
    if (include_filter in line) and (exclude_filter not in line) and (protein_top_list.index(line) % 3 == 0):
        protein_subset.append(line)        

# get the sequence and information of the selected subset from the sequence file:
return_list = []
for i in protein_subset:
    #print(i[1:13])
    for j in protein_seq_list:
        if i[1:13] in j:
            print(j[1:13])
            id_index = protein_seq_list.index(j)
            seq_index = id_index + 1
            return_list.append(protein_seq_list[id_index])
            return_list.append(protein_seq_list[seq_index])

# write the protein subset to a new file
with open("filtered_cluster_reps.fasta", "w") as outfile:
    for line in return_list:
        outfile.write(line + "\n")

#print(protein_subset)
print(return_list[0:6])
print(len(protein_subset))
print(len(return_list))
