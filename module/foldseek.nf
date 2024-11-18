process CREATE_DB_FOLDSEEK_DB {
  input:
    path folder_pdb
    val name_db
  
  output:
    path "db"
  
  script:
  """
    mkdir db
    foldseek createdb $folder_pdb db/$name_db
  """
}
process CREATE_DB_FOLDSEEK_INDEX {
  input:
    path db
    val name_db
  
  output:
    path "db"
  
  script:
  """
    foldseek createindex $db/$name_db tmp
  """
}

process RENAME_FOLDER {
        
    input:
    path folder
    val output_name

    output:
    path output_name

    script: 
    """
        mv $folder $output_name
    """
}


process SEARCH_QUERIES {
  input: 
  path db_reference
  val name_reference
  path db_queries
  val name_queries
  val output_name

  output: 
  path "$output_name.*", emit: allFiles
  path output_name, emit: output_file


script: 
"""
foldseek search \
    $db_reference/$name_reference \
    $db_queries/$name_queries \
    $output_name \
    tmp \
    -a --num-iterations 3 --tmscore-threshold 0.5 --lddt-threshold 0.5 \
    -c 0.7 --cov-mode 2 

"""
}

process CREATE_FOLDSEEK_OUTPUT {
  input:
    path db
    path query
    path output
    path allFiles
    val name_db_ref
    val name_db_query
    val name_output
    val mode

    output:
    path "$name_output.*"

  script: 
  if (mode == "html")
    """
    foldseek convertalis \
      $db/$name_db_ref \
      $query/$name_db_query \
      $output \
      '$name_output'.html \
      --format-mode 3 

    """
  else if (mode == "tsv")
    """
    foldseek convertalis \
      $db/$name_db_ref \
      $query/$name_db_query \
      $output \
      '$name_output'.tsv \
      --format-mode 4 \
     --format-output query,target,fident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,prob,lddt,alntmscore
    """
  else if (mode == "alignment")
    """
      foldseek convertalis \
      $db/$name_db_ref \
      $query/$name_db_query \
      $output \
      '$name_output'_alignment.tsv \
      --format-mode 4 \
    --format-output query,target,qaln,taln
    """

}
