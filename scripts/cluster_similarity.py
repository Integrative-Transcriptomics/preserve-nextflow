# Create a distance matrix from the output of mmseqs2 easy-search
# and Search for proteins that are sufficiently different from ther cluster representative so they have to be looked up separately

import sys
import csv
#import numpy as np

cluster_data_name = sys.argv[1] # Test: /local_scratch/rack/playground/mmseqs2_test/mmseqs2_results/clusterRes_cluster.tsv
distance_data_name = sys.argv[2] # Test: /local_scratch/rack/playground/mmseqs2_test/mmseqs2_results_search/search_result.m8
cluster_members_name = sys.argv[3] # Test: 

cluster_data = []
with open (cluster_data_name) as file:
    cluster_data_file = csv.reader(file, delimiter="\t")
    for line in cluster_data_file:
        cluster_data.append(line)

distance_data = []
with open (distance_data_name) as file:
    distance_data_file = csv.reader(file, delimiter="\t")
    for line in distance_data_file:
        distance_data.append(line[0:3])


print(cluster_data[0:6])
print(distance_data[0:6])