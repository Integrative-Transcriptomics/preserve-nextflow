#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.default_output = "combined_files.fasta"
params.input_files = ["/local_scratch/rack/playground/test_data2/filtered_proteins_HB.fasta",          //from Haiti-B
                      "/local_scratch/rack/playground/test_data2/filtered_proteins_NH.fasta"           //from Nichols Houston
                     ]


/*
 * Combine a number of fasta files into one bigger fasta file.
 */
process combineFiles {

    publishDir "combination_results2", mode: 'copy'

    input:
        val new_name
        path all_files
    
    output:
        path "*"

    script:
    """
    python3 ../scripts/combine_files.py ${new_name} ${all_files}
    """  
   
} 

workflow  {
    
    input_channel = Channel.fromPath(params.input_files).collect()
    input_channel_name = Channel.of(params.default_output)

    combineFiles(input_channel_name, input_channel)
    
}