include { FOLDSEEK } from './subworkflows/foldseek.nf'
include { EXPAND_FOLDSEEK } from './subworkflows/expand_foldseek.nf'
include { FILTER_TMM_CLOSENESS } from './subworkflows/filter_for_TMM_closeness.nf'
include { FILTER_VIA_OPERONS } from './subworkflows/filter_via_operons.nf'
include { EXTRACT_PROMOTERS_ANALYSIS; 
         } from './subworkflows/extract_promoters.nf'
include { FROM_GENES_TO_PROMOTERS } from './subworkflows/from_genes_to_reduced_promoters.nf'

nextflow.preview.output = true


// params.input_queries = "/local_scratch.old/wittepaz/CMFI/PDBS/queries/"
// params.input_references = "/local_scratch.old/wittepaz/CMFI/PDBS/references/"
// params.mmseqs_clustering = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/MMSEQS_clustering/merged_mmseqs_output.tsv"
// params.gff_dir = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/GFFs/"
// params.fasta_dir = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/fastas/"
// params.tmm_results = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/TMMs/merged_results_tmhmm.txt"
// params.gene_ids_to_samples = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/metadata/geneID_toSamples.txt"
// params.metadata_with_species = "/ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/metadata/merged_homologs_samples.csv"
// params.memeDBs = "/ceph/ibmi/it/databases/meme_motifs/motif_databases/"
// params.distance_operons = [150, 250, 350]
// params.distance_TMMs = [300, 450, 600]
// params.ignore_strand = true


workflow {
    FOLDSEEK(params.input_references, params.input_queries)
    EXPAND_FOLDSEEK(FOLDSEEK.out, params.mmseqs_clustering)
    FILTER_TMM_CLOSENESS(params.gff_dir, EXPAND_FOLDSEEK.out,  params.tmm_results, params.distance_TMMs, params.ignore_strand)
    FILTER_VIA_OPERONS(params.gff_dir, EXPAND_FOLDSEEK.out, params.tmm_results, params.gene_ids_to_samples, params.distance_operons)
    EXTRACT_PROMOTERS_ANALYSIS(FILTER_VIA_OPERONS.out.complexes_start, params.fasta_dir, params.gff_dir, params.gene_ids_to_samples, params.memeDBs)
    FROM_GENES_TO_PROMOTERS(EXPAND_FOLDSEEK.out, params.fasta_dir, params.gff_dir, params.gene_ids_to_samples, params.memeDBs, FILTER_VIA_OPERONS.out.all_operons, params.metadata_with_species)
}

output {
    directory params.outputName
    mode "copy"
}