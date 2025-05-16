#!/usr/bin/env nextflow

/*
 * Default Parameters
 */

// Flags for different workflow variants:
params.flag_skip_bakta = false 
params.flag_self_search = true  
// flag for the protein topology determination, signalP is the default option
params.flag_use_deeptmhmm = false
params.flag_use_signalp = true
params.flag_use_neither = false

// Default input for bakta (1)
params.input_files_bakta = [
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/test_data/genomes/treponema_pallidum/Haiti-B.fasta",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/test_data/genomes/treponema_pallidum/Nichols-Houston.fasta"
    ]
//params.input_files_bakta = [
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/accolens.fna",
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/CH_newFasta.fna",
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/CS_newFasta.fna",
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/propinquum.fna",
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/pseudodiphtericum.fna",
//    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/genomes/tuberculosteariucum.fna"
//]

// Parameters for the the combination step (2)
params.combination_name = "combined_fastas_step2.fasta"
// test parameters when bakta is skipped.
params.skip_bakta_faas = [
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/accolens.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/hesseae.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/propinquum.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/pseudodiphtericum.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/simulans.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/proteins/tuberculostearicum.faa",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/staphAureus/Sample_1_filtered.fasta"
    ]

// Default input for deepTMHMMM, for testing purposes (4)
//params.input_file2 = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/deepTMHMM_test/query.fasta"

// Default strictness for the sequence clustering
params.default_id_mmseqs2 = "0.8"
params.default_cov_mmseqs2 = "0.8"

// Test parameters for the filtering step (5)
params.protein_filter_include = "_"
params.protein_filter_exclude = "TestTestTest"
params.input_file_faa = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/deepTMHMM_results/clusterRes_rep_seq.fasta"
//params.input_file_3line = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/deepTMHMM_results/biolib_results/predicted_topologies.3line"
params.input_file_3line = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/Ids/IDS_Lipoprotein_combined.txt"
params.protein_subset = "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/data/data_corynebacteria/subset/Ids/IDS_Lipoprotein_combined.txt"

// Name for the output of step (9) where we select which proteins structures can be gathered from Uniprot
params.name_tsv = "proteins_with_ref.tsv"
params.name_fasta = "proteins_without_ref.fasta"
params.identity_requirement = "0.95"

// test parameters when bakta gets skipped.
params.skip_bakta_jsons = [
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/bakta_results/Haiti-B.fasta_out/Haiti-B.fasta.json",
    "/ceph/ibmi/it/Thor_local_scratch_bkp/rack/playground/workflow_test/bakta_results/Nichols-Houston.fasta_out/Nichols-Houston.fasta.json"
]

// Token and Output folder for step (11)
params.default_token = "+++ Huggingface token +++"
params.esmfold_out = "protein_structures"

// Default name for the folder with the protein structures & clustering requirements
params.default_tm = "0.8"
params.default_cov = "0.8"

//Import Modules
include {useBakta} from "./modules/bakta.nf"
include {useDeepTMHMM} from "./modules/deepTMHMM.nf"
include {filterProteins_DeepTMHMM} from "./modules/filter_proteins_deepTMHMM.nf"
include {useMMSeqs2_EasyCluster} from "./modules/mmseqs2_easycluster.nf"
include {useMMSeqs2_EasySearch} from "./modules/mmseqs2_easysearch.nf"
include {combineFiles} from "./modules/combine_files.nf"
include {findDBComparisonCandidates} from "./modules/compare_DB.nf"
include {getStructures} from "./modules/compare_DB.nf"
include {useESMFOLD} from "./modules/esmFold.nf"
include {getClusterMembers} from "./modules/getClusterMems.nf"
include {evaluateClusters} from "./modules/silhouette_score.nf"
include {useFoldseek_easysearch} from "./modules/foldseek_easysearch.nf"
include {useFoldseek_EasyCluster} from "./modules/foldseek_easycluster.nf"
include {useSignalP6} from "./modules/SignalP.nf"
include {filterProteins_SignalP} from "./modules/filter_proteins_signalP.nf"

workflow {


    if (params.flag_skip_bakta) {
        
        // (1-A) Take direct protein input
        channel_faas = Channel.fromPath(params.skip_bakta_faas).collect()
        channel_jsons = Channel.fromPath(params.skip_bakta_jsons).collect()

    } else {
        
        // (1-B) Get the proteins on the genome from bakta
        input_channel_bakta = Channel.fromPath(params.input_files_bakta)

        useBakta(input_channel_bakta)

        channel_faas = useBakta.out.faa.collect()
        channel_jsons = useBakta.out.json.collect()
    }

    // (2) Collect the protein lists from bakta into a single file
    input_channel_combination_name = Channel.of(params.combination_name)
    combineFiles(input_channel_combination_name, channel_faas)

    // (3) Cluster all proteins
    id_channel_mmseqs2 = Channel.of(params.default_id_mmseqs2)
    cov_channel_mmseqs2 = Channel.of(params.default_cov_mmseqs2)
    useMMSeqs2_EasyCluster(combineFiles.out.view(), id_channel_mmseqs2, cov_channel_mmseqs2)

    
    if (params.flag_use_signalp) {

        // (4-A) Use Signal-P 6 to determine the topology of the cluster representatives
        useSignalP6(useMMSeqs2_EasyCluster.out.reps_fasta)

        // (5-A) Select a subset from the cluster representatives based on their topology, eg: lipoproteins
        input_channel_topologies = useSignalP6.out
        input_channel_filter_inc = Channel.of(params.protein_filter_include)
        input_channel_filter_exc = Channel.of(params.protein_filter_exclude)
        filterProteins_SignalP(useMMSeqs2_EasyCluster.out.reps_fasta, input_channel_topologies, input_channel_filter_inc, input_channel_filter_exc)

        filter_channel = filterProteins_SignalP.out

    } 
    
    if (params.flag_use_deeptmhmm) { 
        
        // (4-B) Use DeepTMHMM to determine the topologies.
        useDeepTMHMM(useMMSeqs2_EasyCluster.out.reps_fasta.view())

        // (5-B) Select a subset from the cluster representatives based on their topology, eg: transmembrane proteins
        input_channel_topologies = useDeepTMHMM.out.topologies
        input_channel_filter_inc = Channel.of(params.protein_filter_include)
        input_channel_filter_exc = Channel.of(params.protein_filter_exclude)
        filterProteins_DeepTMHMM(useMMSeqs2_EasyCluster.out.reps_fasta, input_channel_topologies, input_channel_filter_inc, input_channel_filter_exc)

        filter_channel = filterProteins_DeepTMHMM.out
        
    }

    if (params.flag_use_neither) {

        // (4/5-C) skip protein topology prediction and directly filter by a subset of proteins given by the user.
        input_channel_protein_subset = Channel.fromPath(params.protein_subset)
        input_channel_filter_inc = Channel.of(params.protein_filter_include)
        input_channel_filter_exc = Channel.of(params.protein_filter_exclude)
        filterProteins_DeepTMHMM(useMMSeqs2_EasyCluster.out.reps_fasta, input_channel_protein_subset, input_channel_filter_inc, input_channel_filter_exc)

        filter_channel = filterProteins_DeepTMHMM.out

    }
    
    // (6) Get the cluster members for the representatives and representatives into a big list 
    getClusterMembers(filter_channel, useMMSeqs2_EasyCluster.out.clusters_tsv, combineFiles.out)

    // (7) Search the clusters against themselves 
    useMMSeqs2_EasySearch(getClusterMembers.out)

    // (8) Cluster Quality evaluation: turn mmseqs2 search results into a distance matrix and do silhouette plots on them.
    evaluateClusters(useMMSeqs2_EasySearch.out, useMMSeqs2_EasyCluster.out.clusters_tsv)

    // (9) Check if any of the proteins have structures on UniProt
    input_channel_tsv_name = Channel.of(params.name_tsv)
    input_channel_fasta_name = Channel.of(params.name_fasta)
    input_channel_identity_threshold = Channel.of(params.identity_requirement)
    findDBComparisonCandidates(filter_channel, input_channel_tsv_name, input_channel_fasta_name, input_channel_identity_threshold, channel_jsons)

    // (10) get structures from Uniprot where possible
    getStructures(findDBComparisonCandidates.out.tsv)

    // (11) predict structures for the other proteins
    input_channel_token = Channel.of(params.default_token) // Token for the esmfold prediction
    input_channel_esmfold_out = Channel.of(params.esmfold_out) // Name for the folder that contains the structure predictions
    useESMFOLD(findDBComparisonCandidates.out.fasta, input_channel_token, input_channel_esmfold_out)

    // (12-A) Start of the self search. Compare protein structures with themselves.
    if (params.flag_self_search) {
        channel_protein_folder = useESMFOLD.out.folder.view()
        useFoldseek_easysearch(channel_protein_folder, channel_protein_folder)
    
        tm_score_channel = Channel.of(params.default_tm)
        coverage_channel = Channel.of(params.default_cov)
        useFoldseek_EasyCluster(channel_protein_folder, tm_score_channel, coverage_channel)
    }

}