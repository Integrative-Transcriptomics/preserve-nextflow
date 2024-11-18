
process EXTRACT_PROMOTERS {
    input: 
    tuple val(distance), path(genes_to_extract_promoters)
    path fasta_dir
    path gff_dir
    path samples_to_genes
    each distance_minus
    val distance_in
    output:
    path "promoters_operonDistance_${distance}_${distance_minus}.fa"
    script:
    """
    get_promoter_regions.py  \
    -g $genes_to_extract_promoters  \
    --metadata $samples_to_genes \
    -fastas $fasta_dir \
    -gffs $gff_dir  \
    -d $distance_minus \
    -i $distance_in \
    -o promoters_operonDistance_${distance}_${distance_minus}.fa
    """
}

process EXTRACT_PROMOTERS_AND_OPERONS {
    input: 
    path genes_to_extract_operon_start_and_promoters
    path fasta_dir
    path gff_dir
    path samples_to_genes
    tuple val(operon_distance), path(operon_file)
    each distance_minus
    val distance_in

    output:
    val "promoter${distance_minus}_operon${operon_distance}", emit: keys
    path "promoters_operonDistance_${operon_distance}_${distance_minus}.fa", emit: files
    script:
    """
    get_promoter_regions.py  \
    -g $genes_to_extract_operon_start_and_promoters  \
    --metadata $samples_to_genes \
    -fastas $fasta_dir \
    -gffs $gff_dir  \
    -d $distance_minus \
    -i $distance_in \
    -o promoters_operonDistance_${operon_distance}_${distance_minus}.fa \
    -op  $operon_file
    """
}


process COMPUTE_ENRICHMENT_ANALYSIS {
    input:
    path promoters
    path memeDBs

    output:
    path promoters.baseName
    script:
    """
    xstreme \
        --o $promoters.baseName \
        --p $promoters \
        --order 4 \
        --dna --evt 0.05 --minw 6 --maxw 30 --align right --meme-mod zoops \
        --m $memeDBs/PROKARYOTE/collectf.meme \
        --m $memeDBs/PROKARYOTE/prodoric.meme \
        --m $memeDBs/PROKARYOTE/prodoric_2021.9.meme \
        --m $memeDBs/PROKARYOTE/regtransbase.meme \
        --m $memeDBs/PROKARYOTE/fan2020.meme \
        --m $memeDBs/ECOLI/dpinteract.meme \
        --m $memeDBs/ECOLI/SwissRegulon_e_coli.meme 
    """
}