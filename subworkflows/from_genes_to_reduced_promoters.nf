include {
    EXTRACT_PROMOTERS_AND_OPERONS;
    COMPUTE_ENRICHMENT_ANALYSIS;
   
} from "../module/extract_promoters"

include {
    JOIN_SEQUENCES;
} from "../module/utils"

include {
    REDUCE_TO_ONE_REPRESENTATIVE as REDUCE_IDENTICAL_PROMOTERS;
} from "./reduce_to_one_representative.nf"

include {
    DIVIDE_BY_SPECIES_WORKFLOW;
} from "./divide_by_species.nf"

nextflow.preview.output = true



workflow FROM_GENES_TO_PROMOTERS {
    take: 
        gene_list
        fasta_dir
        gff_dir
        geneID_toSamples
        memeDBs
        operon_mapping
        metadata_with_species

    
    main: 
        multiple_distances = [100, 200, 300, 400]

        EXTRACT_PROMOTERS_AND_OPERONS(gene_list, fasta_dir, gff_dir, geneID_toSamples, operon_mapping,multiple_distances,10 )
        DIVIDE_BY_SPECIES_WORKFLOW(EXTRACT_PROMOTERS_AND_OPERONS.out.keys, EXTRACT_PROMOTERS_AND_OPERONS.out.files, metadata_with_species)
        // DIVIDE_BY_SPECIES_WORKFLOW.out.view()
        // all_keys = DIVIDE_BY_SPECIES_WORKFLOW.out.distances.collect()
        // all_files = DIVIDE_BY_SPECIES_WORKFLOW.out.fastas.collect()
        // all_keys.head()
        // all_files.head()
        REDUCE_IDENTICAL_PROMOTERS(DIVIDE_BY_SPECIES_WORKFLOW.out)
        // all_promoters_grouped = REDUCE_IDENTICAL_PROMOTERS.out.groupTuple()
        // JOIN_SEQUENCES(all_promoters_grouped)
        COMPUTE_ENRICHMENT_ANALYSIS(REDUCE_IDENTICAL_PROMOTERS.out, memeDBs)

    publish:
        EXTRACT_PROMOTERS_AND_OPERONS.out.files >> 'promoters_genes/extracted_promoters'
        REDUCE_IDENTICAL_PROMOTERS.out >> 'promoters_genes/reduced_promoters'
        COMPUTE_ENRICHMENT_ANALYSIS.out >> 'promoters_genes/enrichment_analysis'
}

