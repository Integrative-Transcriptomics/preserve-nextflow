#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.distance_data = "/local_scratch/rack/playground/workflow_test/mmseqs2_results_search/search_result.m8"
params.cluster_data = "/local_scratch/rack/playground/workflow_test/mmseqs2_results/clusterRes_cluster.tsv"

/*
 * Collect a fasta file with a list of all proteins in our subset of interest, cluster members and representatives both
 */
process evaluateClusters {
    conda "../environments/evaluation_env.yml"


    publishDir "cluster_evaluation", mode: 'copy'

    input:
        path search_results
        path cluster_tsv

    output:
        path "*"

    script:
    """
    python3 ../scripts/silhouette_score_test.py ${search_results} ${cluster_tsv}
    """  
   
} 

workflow  {
    
    input_channel_m8 = Channel.fromPath(params.distance_data)
    input_channel_tsv = Channel.fromPath(params.cluster_data)

    evaluateClusters(input_channel_m8, input_channel_tsv)

    
}