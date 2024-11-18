include {
    GET_HOMOLOGS;
    ADAPT_CLUSTERING_MMSEQS;
    EXPAND_USING_MMSEQS
} from "../module/process_foldseek"

nextflow.preview.output = true

workflow EXPAND_FOLDSEEK {
    take:
        output_foldseek
        clustering_mmseqs
    main: 
        GET_HOMOLOGS(output_foldseek)
        ADAPT_CLUSTERING_MMSEQS(clustering_mmseqs)
        EXPAND_USING_MMSEQS(ADAPT_CLUSTERING_MMSEQS.out, GET_HOMOLOGS.out)
    publish:
        GET_HOMOLOGS.out >> 'ExpandFoldseek'
        ADAPT_CLUSTERING_MMSEQS.out >> 'ExpandFoldseek'
        EXPAND_USING_MMSEQS.out.homologs_and_representative >> 'ExpandFoldseek'
        EXPAND_USING_MMSEQS.out.only_homologs >> 'ExpandFoldseek'
    emit:
        EXPAND_USING_MMSEQS.out.only_homologs
        
}