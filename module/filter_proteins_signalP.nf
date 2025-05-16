#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file_seq = "/local_scratch/rack/playground/workflow_test/corynebacteria_run/mmseqs2_results/clusterRes_rep_seq.fasta"
params.input_file_top = "/local_scratch/rack/playground/Signalp_test/Signalp_results/prediction_results.txt"
params.filter_include = "LIPO"
params.filter_exclude = "TestTest"

/*
 * Apply filter the sequence file based on the protein classification from a signalP output file
 */
process filterProteins_SignalP {

    publishDir "filter_results_SignalP", mode: 'copy'

    input:
        path file_path_seq
        path file_path_top
        val filter_string_inc
        val filter_string_exc

    output:
        path "*"

    script:
    """
    python3 ../scripts/filter_proteins_signalp.py ${file_path_seq} ${file_path_top} ${filter_string_inc} ${filter_string_exc}
    """  
   
} 

workflow  {
    
    input_channel_seq = Channel.fromPath(params.input_file_seq)
    input_channel_top = Channel.fromPath(params.input_file_top)
    input_channel_filter_inc = Channel.of(params.filter_include)
    input_channel_filter_exc = Channel.of(params.filter_exclude)

    filterProteins_SignalP(input_channel_seq, input_channel_top, input_channel_filter_inc, input_channel_filter_exc)
    
}