process COMPUTE_OPERONS {
    input:
    each gff
    each operon_distance
   
    output:
    tuple val(operon_distance), path("*.txt")
    
    script:
    """
    infer_operons.py $gff infered_operons_${operon_distance}_${gff.baseName}.txt --distance_operons $operon_distance
    """

}

process REDUCE_OPERONS {
    input:
    tuple val(operon_distance), path(operons)
    path homologs_lipoproteins
    path tmm_proteins

    output:
    tuple val(operon_distance), path("*.txt")
    script: 

    """
    cat $operons | 
        grep -f $homologs_lipoproteins | 
        grep -f $tmm_proteins > reduced_operons_${operons.baseName}.txt
    """
}

process REDUCED_OPERONS_FOLDSEEK {
    input:
    tuple val(operon_distance), path(operons)
    path homologs_lipoproteins

    output:
    tuple val(operon_distance), path("reduced_operons_foldseek_${operons.baseName}.txt")
    script: 

    """
    cat $operons | 
        grep -f $homologs_lipoproteins > reduced_operons_foldseek_${operons.baseName}.txt 
    """
}

process CONCATENATE_OPERONS {
    input:
    tuple val(operon_distance), path(operons)


    output:
    tuple val(operon_distance), path("all_reduced_operons_distance_${operon_distance}.txt")
    script:
    """
    cat $operons > all_reduced_operons_distance_${operon_distance}.txt
    """
}

process REMOVE_SUFFIX {
    input:
    tuple val(operon_distance), path(operons)

    output:
    tuple val(operon_distance), path("${operons.baseName}_no_suffix.txt")

    shell:
    $/
    sed -e "s@\.p01@@g" $operons | sed -e "s@\.r01@@g" > ${operons.baseName}_no_suffix.txt
    /$
}