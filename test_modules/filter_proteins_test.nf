#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file_faa = "/local_scratch/rack/playground/filter_test/Haiti-B.faa"
params.input_file_3line = "/local_scratch/rack/playground/filter_test/predicted_topologies.3line"
params.filter_string = "TM"

/*
 * Apply bakta to a chosen .fasta file
 */
process filterProteins {

    publishDir "filter_results", mode: 'copy'

    input:
        val file_path_faa
        val file_path_3line
        val filter_string

    output:
        path "*"

    script:
    """
    python3 /local_scratch/rack/playground/filter_test/filter_proteins_test.py $file_path_faa $file_path_3line $filter_string 
    """  
   
} 

workflow  {
    
    input_channel_faa = Channel.of(params.input_file_faa)
    input_channel_3line = Channel.of(params.input_file_3line)
    input_channel_filter = Channel.of(params.filter_string)

    filterProteins(input_channel_faa, input_channel_3line, input_channel_filter)
    
}