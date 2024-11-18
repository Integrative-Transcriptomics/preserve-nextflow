include {   CREATE_DB_FOLDSEEK_INDEX; 
            CREATE_DB_FOLDSEEK_DB; 
            RENAME_FOLDER;
            SEARCH_QUERIES; 
            CREATE_FOLDSEEK_OUTPUT;
            CREATE_FOLDSEEK_OUTPUT as CREATE_FOLDSEEK_OUTPUT_HTML } from "../module/foldseek"

nextflow.preview.output = true

workflow FOLDSEEK {
    take:
        reference_folder
        query_folders
    main:
        name_reference = "staph_aureus_lipoproteins"
        name_queries = "search_queries"
        output_name = "CorynebacteriaVsStaphAureus"
        CREATE_DB_FOLDSEEK_REFERENCE(reference_folder, name_reference)
        CREATE_DB_FOLDSEEK_QUERY(query_folders, name_queries)
        SEARCH_QUERIES(CREATE_DB_FOLDSEEK_REFERENCE.out, name_reference, CREATE_DB_FOLDSEEK_QUERY.out, name_queries, output_name)
        CREATE_FOLDSEEK_OUTPUT(CREATE_DB_FOLDSEEK_REFERENCE.out, CREATE_DB_FOLDSEEK_QUERY.out, SEARCH_QUERIES.out.output_file, SEARCH_QUERIES.out.allFiles, name_reference, name_queries, output_name, "tsv")
        CREATE_FOLDSEEK_OUTPUT_HTML(CREATE_DB_FOLDSEEK_REFERENCE.out, CREATE_DB_FOLDSEEK_QUERY.out, SEARCH_QUERIES.out.output_file, SEARCH_QUERIES.out.allFiles, name_reference, name_queries, output_name, "html")
    publish:
        CREATE_FOLDSEEK_OUTPUT.out >> 'Foldseek'
        CREATE_FOLDSEEK_OUTPUT_HTML.out >> 'Foldseek'
    emit:
        CREATE_FOLDSEEK_OUTPUT.out
    
}


workflow CREATE_DB_FOLDSEEK_REFERENCE {
    take:
        reference_folder
        name_db
    main: 
        CREATE_DB_FOLDSEEK_INDEX(CREATE_DB_FOLDSEEK_DB(reference_folder, name_db), name_db)    
    emit: 
        CREATE_DB_FOLDSEEK_INDEX.out
}

workflow CREATE_DB_FOLDSEEK_QUERY {
    take:
        reference_folder
        name_db

    main: 
        RENAME_FOLDER(CREATE_DB_FOLDSEEK_INDEX(CREATE_DB_FOLDSEEK_DB(reference_folder, name_db), name_db), "db_query")
    
    emit: 
        RENAME_FOLDER.out
}
