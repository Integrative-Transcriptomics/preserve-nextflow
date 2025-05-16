#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.default_input = "/local_scratch/rack/playground/workflow_test/corynebacteria_run/mmseqs2_results/clusterRes_rep_seq.fasta"


/*
 * Use SignalP-6 to get pedictions for the proteins
 */
process useSignalP6 {

    conda "../environments/signalp6_environment.yml"
    
    publishDir "Signalp_results", mode: "copy"

    input:
        path protein_file

    output:
        path "**rediction_results.txt"

    script:
    """
    signalp6 -ff ${protein_file} -od . -m slow-sequential
    """

}

workflow {

    input_channel_file = Channel.fromPath(params.default_input)

    useSignalP6(input_channel_file)
}