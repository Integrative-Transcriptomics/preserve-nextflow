#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file = "/local_scratch/rack/data/test_data/genomes/treponema_pallidum/Haiti-B.fasta"

/*
 * Apply bakta to a chosen .fasta file
 */
process useBakta {

    publishDir "test_results", mode: 'copy'

    input:
        val file_path

    output:
        path "*"

    script:
    """
    bakta --db /share/databases/bakta_db-light --output results7 $file_path
    """  
   
} 

workflow  {
    
    input_channel = Channel.of(params.input_file)

    useBakta(input_channel)
    
}