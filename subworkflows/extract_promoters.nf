include {
    EXTRACT_PROMOTERS;
    COMPUTE_ENRICHMENT_ANALYSIS;
   
} from "../module/extract_promoters"

nextflow.preview.output = true

workflow EXTRACT_PROMOTERS_ANALYSIS {
    take:
        genes_to_extract_promoters
        fasta_dir
        gff_dir
        samples_to_genes
        memeDBs

    main: 
        multiple_distances = [100, 200, 300, 400]
        EXTRACT_PROMOTERS(genes_to_extract_promoters, fasta_dir, gff_dir, samples_to_genes, multiple_distances, 10)
        COMPUTE_ENRICHMENT_ANALYSIS(EXTRACT_PROMOTERS.out, memeDBs)

    publish:
        EXTRACT_PROMOTERS.out >> 'promoters_operons/extracted_promoters'
        COMPUTE_ENRICHMENT_ANALYSIS.out >> 'promoters_operons/enrichment_analysis'
        
        

}