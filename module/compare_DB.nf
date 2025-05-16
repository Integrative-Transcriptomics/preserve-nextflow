#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
params.input_file_json1 = "/local_scratch/rack/playground/bakta_test/bakta_results/Haiti-B.fasta_out/Haiti-B.fasta.json"
params.input_file_json2 = "/local_scratch/rack/playground/bakta_test/bakta_results/Nichols-Houston.fasta_out/Nichols-Houston.fasta.json"
params.input_file_fasta = "/local_scratch/rack/playground/workflow_test/filter_results/filtered_cluster_reps.fasta"
params.default_name_tsv = "proteins_with_ref.tsv"
params.default_name_fasta = "proteins_without_ref.fasta"
params.identity_requirement = "0.95"

/*
 * Search through the json from Bakta and the result of the protein filter to make a list of proteins with high identity references
 */
process findDBComparisonCandidates {

    publishDir "compare_results_new", mode: 'copy'

    input:
        path protein_list_fasta
        val name_tsv
        val name_fasta
        val identity_threshold
        path jsons

    output:
        path "**.tsv", emit: tsv
        path "**.fasta", emit: fasta
 
    script:
    """
    python3 ../scripts/find_candidates.py ${protein_list_fasta} ${name_tsv} ${name_fasta} ${identity_threshold} ${jsons}
    """  
   
} 

process getStructures {

    publishDir "structure_files", mode: 'copy'

    input:
        path ref_list

    output:
        path "*", optional: true

    script:
    """
    python3 /local_scratch/rack/playground/compare_DB_test/get_structure.py ${ref_list}
    """  
   
} 

workflow  {
    
    input_channel_jsons = Channel.fromPath([params.input_file_json1, params.input_file_json2])
    input_channel_fasta = Channel.fromPath(params.input_file_fasta)
    input_channel_name_tsv = Channel.of(params.default_name_tsv)
    input_channel_name_fasta = Channel.of(params.default_name_fasta)
    input_channel_identity_reqs = Channel.of(params.identity_requirement)

    findDBComparisonCandidates(input_channel_fasta, input_channel_name_tsv, input_channel_name_fasta, input_channel_identity_reqs, input_channel_jsons.collect())

    getStructures(findDBComparisonCandidates.out.tsv)
    
}