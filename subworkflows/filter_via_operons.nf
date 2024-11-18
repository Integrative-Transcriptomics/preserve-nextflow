include {
    COMPUTE_OPERONS;
    REDUCE_OPERONS;
    REDUCED_OPERONS_FOLDSEEK;
    CONCATENATE_OPERONS; 
    CONCATENATE_OPERONS as CONCATENATE_OPERONS_FOLDSEEK;
    REMOVE_SUFFIX;
    REMOVE_SUFFIX as REMOVE_SUFFIX_FOLDSEEK;
    
   
} from "../module/operon_computation"

include {
    GET_ALL_GENES_IN_OPERONS;
    GET_ALL_COMPLEXES_IN_OPERONS;
    GET_ALL_COMPLEXES_STARTS_IN_OPERONS;
    GET_ALL_LIPOPROTEINS_IN_OPERONS;
    GET_TMMS_IN_OPERONS;
    PRETTY_PRINT_OPERONS
} from "../module/operon_analysis"

nextflow.preview.output = true

workflow FILTER_VIA_OPERONS {
    take:
        gff_dir
        homologs_foldseek
        tmm_proteins
        geneID_toSamples
        distance_operons

    main: 
        gffs = Channel.fromPath("$gff_dir/*.gff")
        COMPUTE_OPERONS(gffs, distance_operons)
        REDUCE_OPERONS(COMPUTE_OPERONS.out, homologs_foldseek, tmm_proteins)
        REDUCED_OPERONS_FOLDSEEK(COMPUTE_OPERONS.out, homologs_foldseek)
        all_reduced_operons = REDUCE_OPERONS.out.groupTuple()
        all_reduced_operons_foldseek = REDUCED_OPERONS_FOLDSEEK.out.groupTuple()
        CONCATENATE_OPERONS(all_reduced_operons)
        CONCATENATE_OPERONS_FOLDSEEK(all_reduced_operons_foldseek)
        REMOVE_SUFFIX(CONCATENATE_OPERONS.out)
        REMOVE_SUFFIX_FOLDSEEK(CONCATENATE_OPERONS_FOLDSEEK.out)
        GET_ALL_GENES_IN_OPERONS(REMOVE_SUFFIX.out)
        GET_ALL_COMPLEXES_IN_OPERONS(REMOVE_SUFFIX.out)
        GET_ALL_COMPLEXES_STARTS_IN_OPERONS(REMOVE_SUFFIX.out)
        all_complexes = GET_ALL_COMPLEXES_IN_OPERONS.out
        GET_ALL_LIPOPROTEINS_IN_OPERONS(GET_ALL_GENES_IN_OPERONS.out, homologs_foldseek)
        all_lipoproteins = GET_ALL_LIPOPROTEINS_IN_OPERONS.out
        GET_TMMS_IN_OPERONS(GET_ALL_GENES_IN_OPERONS.out, tmm_proteins)
        all_tmms = GET_TMMS_IN_OPERONS.out
        all_items = all_lipoproteins.concat(all_tmms, all_complexes)
        grouped_items = all_items.groupTuple()
        // PRETTY_PRINT_OPERONS(GET_ALL_COMPLEXES_IN_OPERONS.out, GET_ALL_LIPOPROTEINS_IN_OPERONS.out, GET_TMMS_IN_OPERONS.out, geneID_toSamples)
        PRETTY_PRINT_OPERONS(grouped_items, geneID_toSamples)

    publish:
        all_reduced_operons >> 'reduced_operons/perSample'
        GET_ALL_GENES_IN_OPERONS.out >> 'reduced_operons/all_reduced_operons_with_tmms'
        CONCATENATE_OPERONS.out >> 'reduced_operons/all_reduced_operons_with_tmms'
        REMOVE_SUFFIX_FOLDSEEK.out >> 'reduced_operons/reduced_operons_only_foldseek'
        GET_ALL_LIPOPROTEINS_IN_OPERONS.out >> 'reduced_operons/all_reduced_operons_with_tmms'
        GET_TMMS_IN_OPERONS.out >> 'reduced_operons/all_reduced_operons_with_tmms'
        PRETTY_PRINT_OPERONS.out >> 'reduced_operons/all_reduced_operons_with_tmms'
        GET_ALL_COMPLEXES_STARTS_IN_OPERONS.out >> 'reduced_operons/call_reduced_operons_with_tmms'

    emit:
        complexes_start = GET_ALL_COMPLEXES_STARTS_IN_OPERONS.out
        all_operons = REMOVE_SUFFIX_FOLDSEEK.out

}