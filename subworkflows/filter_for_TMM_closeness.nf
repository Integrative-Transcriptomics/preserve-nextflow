include {
    GET_LIPOPROTEINS_CLOSE_TO_TMMS;
    SUMMARIZE_LIPOPROTEINS_CLOSE_TO_TMMS
} from "../module/filter_TMMs"

nextflow.preview.output = true

workflow FILTER_TMM_CLOSENESS {
    take:
        gff_dir
        homologs_foldseek
        tmm_proteins
        distance_TMMs
        ignore_strand
        
    main: 
        gffs = Channel.fromPath("$gff_dir/*.gff")
        GET_LIPOPROTEINS_CLOSE_TO_TMMS(gffs, homologs_foldseek, tmm_proteins, distance_TMMs, ignore_strand)
        collected_lipoproteins = GET_LIPOPROTEINS_CLOSE_TO_TMMS.out.groupTuple()
        SUMMARIZE_LIPOPROTEINS_CLOSE_TO_TMMS(collected_lipoproteins)
    publish:
        GET_LIPOPROTEINS_CLOSE_TO_TMMS.out >> 'LipoproteinsCloseToTMMs/perSample'
        SUMMARIZE_LIPOPROTEINS_CLOSE_TO_TMMS.out >> 'LipoproteinsCloseToTMMs'
    emit:
        SUMMARIZE_LIPOPROTEINS_CLOSE_TO_TMMS.out
        
}