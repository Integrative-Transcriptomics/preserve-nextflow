# Step 8 of the pipeline. We take the pairwise distances from mmseqs2 easy-search and create a distance matrix. Scores not in the data are set to 0

import csv
import sys
import sklearn
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from sklearn import metrics


# Import the distances from MMSeqs2 easy-search
distances_data_name = sys.argv[1] # Test: /local_scratch/rack/playground/workflow_test/corynebacteria_run/mmseqs2_results_search/search_result.m8

# Column 1: Protein A, Column 2: Protein B, Column 3: Similarity 
distance_data = []
with open(distances_data_name) as file:
    distance_data_file = csv.reader(file, delimiter="\t")
    for line in distance_data_file:
        distance_data.append(line[0:3])

# Get a list of unique proteins from the distance data for the matrix dimensions (cluster members)
protein_list = []
for i in distance_data:
    if i[0] not in protein_list:
        protein_list.append(i[0])
    if i[1] not in protein_list:
        protein_list.append(i[1])

# Create a NxN array of zeroes where N is the number of unique proteins:
distance_matrix = np.zeros((len(protein_list), len(protein_list)))

# Fill the distance matrix with the information from the clustering
for i in distance_data:
    row = protein_list.index(i[0])
    column = protein_list.index(i[1])
    identity = i[2]
    distance_matrix[row][column] = identity

# Import the classifications from MMSeqs2 clustering
clustering_data_name = sys.argv[2] # Test: /local_scratch/rack/playground/workflow_test/corynebacteria_run/mmseqs2_results/clusterRes_cluster.tsv

# Column 1: Representative, Column 2: Cluster Member
clustering_data = []
with open(clustering_data_name) as file:
    for line in file:
        l = line.strip().split("\t")
        clustering_data.append(l)

# get the representative for each protein in the protein list
labels = []
for i in protein_list:
    for j in clustering_data:
        if i == j[1]:
            labels.append(j[0])

# Compute silhouette score per sample
sample_silhouette_score = sklearn.metrics.silhouette_samples(distance_matrix, labels)
mean_silhouette_score = sklearn.metrics.silhouette_score(distance_matrix, labels)

#print(distance_matrix)
#print(len(distance_data))
#print(protein_list[0:3])
#print(len(protein_list))

#print(clustering_data[0:3])

#print("labels length = " + str(len(labels)))
#print(labels[0:5])
#print(mean_silhouette_score)
#print(sample_silhouette_score)

clusters = []
for i in labels:
    if i not in clusters:
        clusters.append(i)

# Calculate silhouette score per cluster and make a bar plot.
cluster_silhouette_score = []
for i in clusters:
    silhouette_scores_i = []
    cluster_members_i = []

    #find the cluster members of cluster i
    for j in clustering_data:
        if i == j[0]:
            cluster_members_i.append(j[1])

    # add up the silhouette scores of the cluster members:
    for j in cluster_members_i:
        member_index = protein_list.index(j)
        member_score = sample_silhouette_score[member_index]
        silhouette_scores_i.append(member_score)

    # calculate average score
    silhouette_score_i = np.average(silhouette_scores_i)
    cluster_silhouette_score.append(silhouette_score_i)

    # create plot

    plt.barh(cluster_members_i, silhouette_scores_i)

    plt.title("Silhouette scores for the cluster of " + i)
    plt.xlabel("Score")
    plt.ylabel("Members")
    plt.subplots_adjust(left=0.21)
    #plt.xlim(-1,1)
    #plt.show()

    #print(len(cluster_members_i))

    #if clusters.index(i) == 1:
    plt.savefig("plot_" + i +"_.png")

    plt.clf()

#print(cluster_silhouette_score)
#print(len(cluster_silhouette_score))

# write output to file
with open("cluster_evaluation_sequence.txt", "w") as outfile:
    outfile.write("Average Silhouette Score:" + str(mean_silhouette_score) + "\n")
    outfile.write("Silhouette Scores by Cluster representative: \n")
    for i in cluster_silhouette_score:
        outfile.write(clusters[cluster_silhouette_score.index(i)] + "\t" + str(i) + "\n")

