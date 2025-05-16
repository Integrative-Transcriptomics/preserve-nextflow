#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file = [
    "/local_scratch/rack/data/test_data/genomes/treponema_pallidum/Haiti-B.fasta",
    "/local_scratch/rack/data/test_data/genomes/treponema_pallidum/Nichols-Houston.fasta"
    ]
/*
 * Apply bakta to a chosen .fasta file
 */
process useBakta {

    publishDir "bakta_results", mode: 'copy'

    input:
        path file_path

    output:
        path "**${file_path}.faa"  , emit: faa
        path "**${file_path}.json" , emit: json

    script:
    """
    bakta --db /share/databases/bakta_db-light --skip-plot --output ${file_path}_out --prefix ${file_path} $file_path
    """  
   
} 

workflow  {
    
    input_channel = Channel.fromPath(params.input_file)

    useBakta(input_channel)
    
}