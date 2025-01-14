#!/usr/bin/env nextflow

/*
 * Default Parameters
 */ 
params.input_file = "/local_scratch/rack/playground/deepTMHMM_test/query.fasta"
//params.input_file = "/local_scratch/rack/playground/workflow_test/test_results/results7/Haiti-B.faa"

/*
 * test DeepTMHMM on a query file
 * Needs to be run in the Conda deepTMHMM environment -> conda activate deepTMHMM
 */
process useDeepTMHMM {
    conda '/local_scratch/rack/playground/deepTMHMM_test/deepTMHMM_environment.yml'

    publishDir "test_results", mode: 'copy'

    input:
        val file_path    

    output:
        path "*"    

    script:
    //"""
    //biolib run DTU/DeepTMHMM --fasta $file_path
    //"""
    """
    biolib run --local 'DTU/DeepTMHMM:1.0.24' --fasta $file_path
    """
}

workflow {

    input_channel = Channel.of(params.input_file)

    useDeepTMHMM(input_channel)

}