# Input1: .fasta list of cluster representatives who are in the protein class of interest, from filter_proteins eg: Transmembrane proteins
# Path: /local_scratch/rack/playground/filter_test/filter_results/filtered_proteins.fasta
# Input2: .tsv of all proteins with their assigned cluster representative from mmseqs2 easy-cluster
# Path: /local_scratch/rack/playground/workflow_test/mmseqs2_results/clusterRes_cluster.tsv
# Input3: .fasta list of all proteins so we can get the sequences for the cluster members
# Path: /local_scratch/rack/playground/workflow_test/combination_results2/combined_fastas_step2.fasta
# Output: .fasta list of all cluster representatives and members

import sys

# Reading in input 1
cluster_reps_name = sys.argv[1] # Test: /local_scratch/rack/playground/workflow_test/filter_results/filtered_cluster_reps.fasta
cluster_rep_list = []
with open(cluster_reps_name) as file:
    for line in file:
        rep_id = line[1:13]
        cluster_rep_list.append(rep_id)

# Remove the sequences from the list of Rep Ids
rep_ids = []
for i in cluster_rep_list:
    if cluster_rep_list.index(i) % 2 == 0:
        rep_ids.append(i)

# Reading in input 2
clusters_name = sys.argv[2] # Test: /local_scratch/rack/playground/workflow_test/mmseqs2_results/clusterRes_cluster.tsv
clustering = []
with open(clusters_name) as file:
    for line in file:
        l = line.strip().split("\t")
        clustering.append(l)

# reading in input 3
protein_seqs_name = sys.argv[3] # Test: /local_scratch/rack/playground/workflow_test/combination_results2/combined_fastas_step2.fasta
all_proteins = []
with open(protein_seqs_name) as file:
    for line in file:
        all_proteins.append(line.strip())

# Select the lines from clustering that correspond to cluster reps we want.
cluster_subset = []
for i in clustering:
    for j in rep_ids:
        if i[0] in j:
            cluster_subset.append(i)

# Go through the list of our relevant cluster members and get their sequences from input 3
protein_subset = []
for i in cluster_subset:
    for j in all_proteins:
        if i[1] in j:
            index_id = all_proteins.index(j)
            index_seq = all_proteins.index(j) + 1
            protein_subset.append(all_proteins[index_id])
            protein_subset.append(all_proteins[index_seq])
        
# Write the chosen proteins with their sequences to a .fasta file:
with open("Cluster_proteins.fasta", "w") as outfile:
    for line in protein_subset:
        outfile.write(line + "\n")


print("----------------------")
print(rep_ids[0:3])
print("rep_ids length:" + str(len(rep_ids)))
print("----------------------")
print(clustering[0:3])
print("clustering length: " + str(len(clustering)))
print("----------------------")
print(all_proteins[0:3])
print("all_proteins length:" + str(len(all_proteins)))
print(cluster_subset[0:3])
print("cluster_subset length:" + str(len(protein_subset)))
