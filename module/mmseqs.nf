
process CREATE_DB {
    maxForks 6
    input:
    tuple val(distances), path(lipoproteins)
    output:
    tuple val(distances), path("${distances}_db/db_mmseqs_${lipoproteins.simpleName}")
    script:
    """
    mkdir -p ${distances}_db
    mkdir -p ${distances}_db/db_mmseqs_${lipoproteins.simpleName}
    mmseqs createdb $lipoproteins ${distances}_db/db_mmseqs_${lipoproteins.simpleName}/db_lipoproteins
    """
}

process COMPUTE_SIMILARITY {
    maxForks 3
    input: 
    tuple val(distances), path(outputPath)
    output:
    tuple val(distances), path(outputPath)
    script:
    """
    mmseqs search \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins_similarity \
        tmp \
        --threads 2 \
        --search-type 3

    """
    
}

process CREATE_SIMILARITY_OUTPUT {
    input: 
    tuple val(distances), path(outputPath)
    output:
    tuple val(distances), path("db_lipoproteins_similarity_${outputPath.simpleName}.tsv")
    script:
    """
    mmseqs createtsv \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins_similarity \
        db_lipoproteins_similarity_${outputPath.simpleName}.tsv \
        --threads 4 \
    """
}

process CLUSTER_DB {
    input: 
    tuple val(distances), path(outputPath)
    val similarityThreshold
    output:
    tuple val(distances), path(outputPath)
    script:
    """
    mmseqs cluster \
        --threads 4 \
        --min-seq-id $similarityThreshold \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins_cluster \
        tmp
    """
}

process CREATE_CLUSTERING_OUTPUT {
    input: 
    tuple val(distances), path(outputPath)
    output:
    tuple val(distances), path("db_lipoproteins_cluster_${outputPath.simpleName}.tsv")
    script:
    """
    mmseqs createtsv \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins_cluster \
        db_lipoproteins_cluster_${outputPath.simpleName}.tsv \
        --threads 4
    """
}

process CREATE_FASTA_REPRESENTATIVES {
    input: 
    tuple val(distances), path(outputPath)
    output:
    tuple val(distances), path("${outputPath}")
    script:
    """
    mmseqs result2repseq \
        ${outputPath}/db_lipoproteins \
        ${outputPath}/db_lipoproteins_cluster \
        ${outputPath}/db_lipoproteins_cluster_representatives
    """
}

process FROM_DB_TO_FASTA {
    input: 
    tuple val(distances), path(outputPath)
    output:
    tuple val(distances), path("cluster_representative_sequences_${outputPath.simpleName}.fasta")
    script: 
    """
    mmseqs convert2fasta \
        ${outputPath}/db_lipoproteins_cluster_representatives \
        cluster_representative_sequences_${outputPath.simpleName}.fasta
    """

}

process CREATE_SUBFOLDER{
    input: 
    val distances 
    each lipoproteins
    output:
    path "${lipoproteins.simpleName}_db"
    script:
    """
    mkdir -p ${lipoproteins.simpleName}_db
    """
}