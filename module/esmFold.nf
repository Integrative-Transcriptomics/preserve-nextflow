#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.protein_list_file = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/esmFold_test/treponema_example.fasta"
params.default_token = "+++ Huggingface token +++"
params.default_out_folder = "protein_structures"

/*
 * Apply esmFold to the proteins in a chosen .fasta file
 */
process useESMFOLD {
    //conda '/local_scratch/rack/playground/esmFold_test/ESMFold_environment2.yml'
    conda "../environments/ESMFold_environment.yml"

    publishDir "structure_files", mode: 'copy'

    input:
        file protein_list
        val esmfold_token
        val output_folder

    output:
        path "${output_folder}", emit: folder, optional: true

    script:
    """
    python3 ../scripts/esmFold.py --token ${esmfold_token} --file ${protein_list} --output ${output_folder}
    """  
   
} 

workflow  {
    
    input_channel_file = Channel.fromPath(params.protein_list_file)
    input_channel_token = Channel.of(params.default_token)
    input_channel_folder = Channel.of(params.default_out_folder)

    useESMFOLD(input_channel_file, input_channel_token, input_channel_folder)
    
}