#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file = "/local_scratch/rack/playground/mmseqs2_test/DB.fasta"

/*
 * test MMSeqs on a query file
 */
process useMMSeqs2 {

    publishDir "test_results_1", mode: 'copy'
    container "soedinglab/mmseqs2"

    input:
        val file_path    

    output:
        path "*"    


    script:
    """
    mmseqs easy-cluster $file_path clusterRes tmp --min-seq-id 0.5 -c 0.8 --cov-mode 1
    """

}

workflow {

    input_channel = Channel.of(params.input_file)

    useMMSeqs2(input_channel)

}