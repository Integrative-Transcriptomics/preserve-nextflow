#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.default_folder = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/corynebacteria_run/structure_files"


/*
 * Call foldseek easy-search to search a query protein against a the other proteins
 */
process useFoldseek_easysearch {
    
    publishDir "foldseek_easysearch_results_corynes", mode: "copy"

    input:
        val query_folder
        val target_folder

    output:
        path "*"

    script:
    """
    foldseek easy-search ${query_folder} ${target_folder} aln tmpFolder --format-output "query,target,qtmscore,ttmscore,fident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits"
    """

}

workflow {

    input_channel_folder = Channel.of(params.default_folder)

    useFoldseek_easysearch(input_channel_folder, input_channel_folder)

}
