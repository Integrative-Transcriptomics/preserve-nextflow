# lipo-search
A repository for the Nextflow Pipeline that optimally predicts the structure of Lipoproteins and searches for structural homologs within a set of lipoprotein references. 

# config-file

The lipo-search pipeline works with the following configuration:

params {
    input_queries = [path_for_PDB_files]
    input_references = [path_for_reference_files]
    mmseqs_clustering = [path_for_results_of_MMSEQS_clustering]
    gff_dir = [path_for_GFF_files_of_samples]
    fasta_dir = [path_for_FASTA_files_of_samples]
    tmm_results = [path_to_deep_TMHMM_file] # this version of the pipeline allows users to predict TM proteins and expects them to be close to the lipoproteins identified. 
    gene_ids_to_samples = [path_to_connect_genes_to_samples] # as produced by bakta or prokka e.g. gene ID to sample ID
    distance_operons = [150] // distance between genes to be chosen as operons
    distance_TMMs = [300] // distance of lipoprotein to a transmembrane proteins to expect the structure of a SID-binding uptake system
    ignore_strand = true // should the strand be ignored to find a TMM protein?
    metadata_with_species = [path_to_metadata] # eg. mapping of samples ID to species names
    outputName = [output_name]

}

