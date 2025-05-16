#!/usr/bin/env nextflow

/*
 * Default Parameters
 */ 
params.input_file = ["/local_scratch/rack/playground/bakta_test/bakta_results/Nichols-Houston.fasta_out/Nichols-Houston.fasta.faa",
                     "/local_scratch/rack/playground/bakta_test/bakta_results/Haiti-B.fasta_out/Haiti-B.fasta.faa"
                    ] 
//params.input_file = "/local_scratch/rack/playground/bakta_test/results7/Haiti-B.faa"

/*
 * test DeepTMHMM on a query file
 * Needs to be run in the Conda deepTMHMM environment -> conda activate deepTMHMM
 */
process useDeepTMHMM {
    conda '../environments/deepTMHMM_environment.yml'

    publishDir "deepTMHMM_results", mode: 'copy'

    input:
        path file_path    

    output:
        path "**/predicted_topologies.3line", emit: topologies
        path "${file_path}", emit: prots
        //tuple val (file_path), val ("*/predicted_topologies.3line")    

    script:
    """
    biolib run --local 'DTU/DeepTMHMM:1.0.24' --fasta $file_path
    """
}

workflow {

    input_channel = Channel.fromPath(params.input_file)

    useDeepTMHMM(input_channel)

}