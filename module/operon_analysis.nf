process GET_ALL_GENES_IN_OPERONS {
    input: 
    tuple val(distance), path(operons)
    output:
     tuple val(distance), path("all_genes_in_operons_distance_${distance}.txt")
    script:
    """
    cut -f1 $operons > all_genes_in_operons_distance_${distance}.txt
    """
}

process GET_ALL_COMPLEXES_IN_OPERONS {
    input: 
    tuple val(distance), path(all_reduced_operons)


    output:
    tuple val(distance), path("all_reduced_operons_distance_${distance}.txt")
    script:
    """
    cut -f3 $all_reduced_operons | sort | uniq > all_reduced_operons_distance_${distance}.txt
    """
}
process GET_ALL_COMPLEXES_STARTS_IN_OPERONS {
    input: 
    tuple val(distance), path(all_reduced_operons)


    output:
    tuple val(distance), path("all_reduced_operon_starts_distance_${distance}.txt")
    script:
    """
    cut -f2 $all_reduced_operons | sort | uniq > all_reduced_operon_starts_distance_${distance}.txt
    """
}

process GET_ALL_LIPOPROTEINS_IN_OPERONS {
    input:
    tuple val(distance), path(all_genes_operons)
    path all_lipoproteins

    output:
    tuple val(distance), path("all_lipoproteins_in_operons_distance_${distance}.txt")
    script:
    """
    grep -f $all_genes_operons $all_lipoproteins > all_lipoproteins_in_operons_distance_${distance}.txt
    """
}

process GET_TMMS_IN_OPERONS {
    input:
    tuple val(distance), path(all_genes_operons)
    path tmm_proteins

    output:
    tuple val(distance), path("tmm_proteins_in_operons_distance_${distance}.txt")
    script:
    """
    grep -f $all_genes_operons $tmm_proteins > tmm_proteins_in_operons_distance_${distance}.txt
    """
}

process PRETTY_PRINT_OPERONS {
    input:
    tuple val(distance), path(all_genes_operons)
    path gene_ids_to_samples

    output:
    path "pretty_printed_operons_distance_${distance}.txt"
    script:
    """
    echo $all_genes_operons

    pretty_output_complexes.py \
        $gene_ids_to_samples \
        $all_genes_operons \
        pretty_printed_operons_distance_${distance}.txt
    """
}