#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file = "/local_scratch/rack/playground/workflow_test/getMembers_results/Cluster_proteins.fasta"

/*
 * test MMSeqs easy-search on a query file against the same file to find cluster identity
 */
process useMMSeqs2_EasySearch {

    publishDir "mmseqs2_results_search", mode: 'copy'
    container "soedinglab/mmseqs2"

    input:
        val file_path    

    // returns an .m8 file. Column 1 corresponds to the query, 2 to the target, and 3 is the sequence identity.
    output:
        path "**result.m8"    


    script:
    """
    mmseqs easy-search $file_path $file_path search_result.m8 tmp -s 7.5
    """

}

workflow {

    input_channel = Channel.of(params.input_file)

    useMMSeqs2_EasySearch(input_channel)

}