#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_folder = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/structure_files"
params.default_tm = "0.8"
params.default_cov = "0.8"

/*
 * apply foldseek easy-cluster to a folder
 */
process useFoldseek_EasyCluster {

    publishDir "foldseek_easycluster_results_treponema", mode: 'copy'

    input:
        val folder_path     
        val tm_requirement
        val cov_requirement

    output:
        path "**rep_seq.fasta" , emit: fold_reps
        path "**.tsv", emit: fold_clusters

    script:
    """
    foldseek easy-cluster ${folder_path} clusterRes tmp --tmscore-threshold ${tm_requirement} -c ${cov_requirement} --cov-mode 0
    """

}

workflow {

    input_channel = Channel.of(params.input_folder)
    tm_score_channel = Channel.of(params.default_tm)
    coverage_channel = Channel.of(params.default_cov)

    useFoldseek_EasyCluster(input_channel, tm_score_channel, coverage_channel)

}