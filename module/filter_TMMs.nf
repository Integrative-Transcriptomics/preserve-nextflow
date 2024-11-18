
process GET_LIPOPROTEINS_CLOSE_TO_TMMS {
    input:
    each gff
    path homologs_foldseek
    path tmm_proteins
    each distance_TMMs
    val ignore_strand
    output:
    tuple val(distance_TMMs), path("lipoproteins_close_to_tmms_$distance_TMMs/*")
    
    script:
    """
    mkdir -p lipoproteins_close_to_tmms_$distance_TMMs
    # Check if ignore_strand is true
    if $ignore_strand; then
        filter_lipoproteins.py \
            $homologs_foldseek \
            $tmm_proteins \
            $gff \
            --threshold $distance_TMMs \
            --ignore-strand \
            --output lipoproteins_close_to_tmms_$distance_TMMs
    else
        filter_lipoproteins.py \
            $homologs_foldseek \
            $tmm_proteins \
            $gff \
            --threshold $distance_TMMs \
            --output lipoproteins_close_to_tmms_$distance_TMMs
    fi
    """

}
    
process SUMMARIZE_LIPOPROTEINS_CLOSE_TO_TMMS {
    input: 
    tuple val(distance), path(lipoproteins_close_to_tmms)
    output:
    path "lipoproteins_close_to_tmms_summary_distance_${distance}.txt"
    script:
    """
    cat $lipoproteins_close_to_tmms > lipoproteins_close_to_tmms_summary_distance_${distance}.txt
    """

}

