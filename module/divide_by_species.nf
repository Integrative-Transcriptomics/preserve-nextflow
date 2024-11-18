
process DIVIDE_BY_SPECIES {
    input: 
    val distances
    path promoters_fasta
    path metadata_file

    output:
    tuple val(distances), path("*fasta")
    script:
    """
        separate_by_species.py --fasta-in $promoters_fasta --output ${distances}_divided_by_species --metadata $metadata_file
    """
}