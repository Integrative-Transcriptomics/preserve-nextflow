process JOIN_SEQUENCES {
    input: 
    tuple val(distance), path(fastas)
    output:
    path "joined_sequences_${distance}.fasta"
    script:
    """
    cat ${fastas.join(' ')} > joined_sequences_${distance}.fasta
    """
}

process ADAPT_FASTA {
    input: 
    path fasta
    output:
    path "${fasta.simpleName}_adapted.fasta"
    script:
    """
    adapt_fasta.py $fasta ${fasta.simpleName}_adapted.fasta
    """
}

// process DISTRIBUTE_KEY {
//     input: 
//     val distance
//     path fastas
//     output:
//     tuple val(distance), path(fastas) 
//     script:
//      fastas.each {file –> tuple(val(distance), file)}
    

   
// }