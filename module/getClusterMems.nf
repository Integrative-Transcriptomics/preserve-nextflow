#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.cluster_reps_fasta = "/local_scratch/rack/playground/workflow_test/filter_results/filtered_cluster_reps.fasta"
params.clustering_data = "/local_scratch/rack/playground/workflow_test/mmseqs2_results/clusterRes_cluster.tsv"
params.all_proteins_fasta = "/local_scratch/rack/playground/workflow_test/combination_results2/combined_fastas_step2.fasta"

/*
 * Collect a fasta file with a list of all proteins in our subset of interest, cluster members and representatives both
 */
process getClusterMembers {

    publishDir "getMembers_results", mode: 'copy'

    input:
        path cluster_representatives_fasta
        path clustering_tsv
        path protein_list_fasta

    output:
        path "*"

    script:
    """
    python3 ../scripts/getClusterMembers.py ${cluster_representatives_fasta} ${clustering_tsv} ${protein_list_fasta}
    """  
   
} 

workflow  {
    
    input_channel_Clreps = Channel.fromPath(params.cluster_reps_fasta)    
    input_channel_tsv = Channel.fromPath(params.clustering_data)
    input_channel_members = Channel.fromPath(params.all_proteins_fasta)

    getClusterMembers(input_channel_Clreps, input_channel_tsv, input_channel_members)

    
}