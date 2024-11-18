process GET_HOMOLOGS {
    input:
    path result_foldseek

    output:
    path "homologs_foldseek.txt"

    script:
    """
    cat $result_foldseek |
    cut -f 2 | 
    # remove everything between "_unrelaxed_rand" and "000"
    sed 's/_unrelaxed_rank.*000.pdb//g' |
    # Cut at .p01
   sed 's/.p01//g' |
    sort | 
    uniq > homologs_foldseek.txt
    """
}

process ADAPT_CLUSTERING_MMSEQS {
    input:
    path clustering_mmseqs

    output:
    path "adapted_clustering_mmseqs.txt"

    script:
    """
    sed 's/.p01//g' $clustering_mmseqs > adapted_clustering_mmseqs.txt
    """

}

process EXPAND_USING_MMSEQS {
    input:
    path clustering_mmseqs
    path homologs_foldseek

    output:
    path "expanded_homologs_with_identical_representative.txt", emit: homologs_and_representative
    path "putative_homologs_foldseek.txt", emit: only_homologs

    script:
    """
    cat $clustering_mmseqs |
    grep -f $homologs_foldseek > expanded_homologs_with_identical_representative.txt
    cut -f 2 expanded_homologs_with_identical_representative.txt > putative_homologs_foldseek.txt
    """
}