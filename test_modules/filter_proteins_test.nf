#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
//params.input_tuple = tuple val ("/local_scratch/rack/playground/filter_test/Haiti-B.faa"), val ("/local_scratch/rack/playground/filter_test/predicted_topologies.3line") 
params.input_file_faa = "/local_scratch/rack/playground/workflow_test/deepTMHMM_results/clusterRes_rep_seq.fasta"
params.input_file_3line = "/local_scratch/rack/playground/workflow_test/deepTMHMM_results/biolib_results/predicted_topologies.3line"
params.filter_include = "TM"
params.filter_exclude = "SP"

/*
 * Apply filter a faa file based on the protein classification from a 3line file
 */
process filterProteins {

    publishDir "filter_results", mode: 'copy'

    input:
        //tuple val (file_path_faa), val (file_path_3line)
        path file_path_faa
        path file_path_3line
        val filter_string_inc
        val filter_string_exc

    output:
        path "*"

    script:
    """
    python3 /local_scratch/rack/playground/filter_test/filter_proteins_test.py $file_path_faa $file_path_3line $filter_string_inc $filter_string_exc
    """  
   
} 

workflow  {
    
    //input_channel_tuple = Channel.of(params.input_tuple)
    //input_channel_tuple = Channel.of([params.input_file_faa, params.input_file_3line])
    input_channel_faa = Channel.fromPath(params.input_file_faa)
    input_channel_3line = Channel.fromPath(params.input_file_3line)
    input_channel_filter_inc = Channel.of(params.filter_include)
    input_channel_filter_exc = Channel.of(params.filter_exclude)

    filterProteins(input_channel_faa, input_channel_3line, input_channel_filter_inc, input_channel_filter_exc)
    
}