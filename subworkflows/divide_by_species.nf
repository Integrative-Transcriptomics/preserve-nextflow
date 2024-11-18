include {
    DIVIDE_BY_SPECIES;
} from "../module/divide_by_species"

workflow DIVIDE_BY_SPECIES_WORKFLOW {
    take:
        distances_as_key
        fastas_as_value
        metadata_file
    main:
        DIVIDE_BY_SPECIES(distances_as_key, fastas_as_value, metadata_file)
        DIVIDE_BY_SPECIES.out.transpose().set {transposed}
    emit:
        transposed
    publish:
        DIVIDE_BY_SPECIES.out >> "PROMOTERS_BY_SPECIES"
}