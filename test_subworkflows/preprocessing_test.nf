#!/usr/bin/env nextflow

/*
 * Default Parameters
 */
// Default input for bakta 
params.input_file1 = "/local_scratch/rack/data/test_data/genomes/treponema_pallidum/Haiti-B.fasta"
params.protein_filter = "TM"

// Default input for deepTMHMMM, for testing purposes
//params.input_file2 = "/local_scratch/rack/playground/deepTMHMM_test/query.fasta"

//Import Modules
include {useBakta} from "/local_scratch/rack/playground/bakta_test/bakta_test.nf"
include {useDeepTMHMM} from "/local_scratch/rack/playground/deepTMHMM_test/deepTMHMM_test.nf"
include {filterProteins} from "/local_scratch/rack/playground/filter_test/filter_proteins_test.nf"
include {useMMSeqs2} from "/local_scratch/rack/playground/mmseqs2_test/mmseqs2_test.nf"

workflow {

    input_channel1 = Channel.of(params.input_file1)
    input_channel_filter = Channel.of(params.protein_filter)

    useBakta(input_channel1)

    useDeepTMHMM(useBakta.out)

    filterProteins(useBakta.out, useDeepTMHMM.out, input_channel_filter)

    useMMSeqs2(filterProteins.out)

}