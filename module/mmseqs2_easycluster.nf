#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file = "/local_scratch/rack/playground/workflow_test/combination_results2/combined_fastas_step2.fasta"
params.default_id_mmseqs2 = "0.8"
params.default_cov_mmseqs2 = "0.8"

/*
 * test MMSeqs on a query file
 */
process useMMSeqs2_EasyCluster {

    publishDir "mmseqs2_results", mode: 'copy'
    container "soedinglab/mmseqs2"

    input:
        val file_path      
        val id_requirement_mmseqs2
        val cov_requirement_mmseqs2

    output:
        path "**rep_seq.fasta" , emit: reps_fasta
        path "**.tsv", emit: clusters_tsv

    script:
    """
    mmseqs easy-cluster $file_path clusterRes tmp --min-seq-id ${id_requirement_mmseqs2} -c ${cov_requirement_mmseqs2} --cov-mode 0
    """

}

workflow {

    input_channel = Channel.of(params.input_file)
    id_channel_mmseqs2 = Channel.of(params.default_id_mmseqs2)
    cov_channel_mmseqs2 = Channel.of(params.default_cov_mmseqs2)

    useMMSeqs2_EasyCluster(input_channel, id_channel_mmseqs2, cov_channel_mmseqs2)

}