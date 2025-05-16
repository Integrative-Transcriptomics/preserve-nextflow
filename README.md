# PRESERVE Nextflow
A repository for the Nextflow Pipeline that optimally predicts the structure of proteins and searches for structural homologs within a set of references or within the provided set of predicted proteins. . 

# config-file

The pipeline works with the following configuration:
```sh
params {
    input_queries = [path_for_PDB_files]
    input_references = [path_for_reference_files]
    mmseqs_clustering = [path_for_results_of_MMSEQS_clustering]
    gff_dir = [path_for_GFF_files_of_samples]
    fasta_dir = [path_for_FASTA_files_of_samples]
    tmm_results = [path_to_deep_TMHMM_file] # this version of the pipeline allows users to predict TM proteins and expects them to be close to the lipoproteins identified. 
    gene_ids_to_samples = [path_to_connect_genes_to_samples] # as produced by bakta or prokka e.g. gene ID to sample ID
    distance_operons = [150] // distance between genes to be chosen as operons
    distance_TMMs = [300] // distance of lipoprotein to a transmembrane proteins to expect the structure of a SID-binding uptake system
    ignore_strand = true // should the strand be ignored to find a TMM protein?
    metadata_with_species = [path_to_metadata] # eg. mapping of samples ID to species names
    outputName = [output_name]

}
```
# PRESERVE - Raffael BA version
This repository holds the PRESERVE pipeline, a pipeline intended to identify homologous proteins in prokaryotes across taxon borders using a joint sequence and structure data approach.

## Profiles
PRESERVE has different profiles that allow the user to customize their runs by using different tools.

### Skip Bakta
This profile allows the User to bypass the genome annotation step at the beginning of the pipeline.\
It can be called from the command line with:
```sh
nextflow run PRESERVE.nf -p skip_bakta
```
If this option is chosen, the user needs to provide the protein data themselves:
```sh
params.skip_bakta_faas = [
    [path to file with proteins 1],
    [path to file with proteins 2],
    ...
]
```
Additionally, if the user wants to make use of the UniRef query, they can provide jsons with references themselves. These do need to be formatted like Bakta's json output:
```sh
params.skip_bakta_jsons = [
    [path to json 1],
    [path to json 2],
    ...
]
```
If the user does NOT use this profile, input genomes have to be provided as follows:
```sh
params.input_files_bakta = [
    [path to fasta file with genomes 1],
    [path to fasta file with genomes 2],
    ...
]
```
### Topology selection

There are three ways to do topology selection in PRESERVE: with SignalP-6, with DeepTMHMM, and with a user-specified protein set.\
These are each associated with a profile explained below:

#### SignalP-6
This profile configures the pipeline to use SignalP-6 for topology prediction based on signal peptides. It is used with this command:
```sh
nextflow run PRESERVE.nf -p use_SignalP
```
SignalP-6 can identify the following types of proteins:\
1. SP:        Proteins of the secretion route cleaved by SPase I 
2. LIPO:      Proteins of the secretion route cleaved by SPase II (Lipoproteins) 
3. PILIN:     Proteins of the secretion route cleaved by SPase III
4. TAT:       Proteins in the twin-arginine pathway cleaved by SPase I 
5. TATLIPO:   Proteins in the twin-arginine pathway cleaved by SPase II (Lipoproteins) 
6. OTHER      All other proteins
The selection defaults to Lipoproteins, specifically LIPO and TATLIPO but can also be customized to in- or exclude certain strings:
```sh
params.protein_filter_include = [string to include]
params.protein_filter_exclude = [string to exclude]
```
#### DeepTMHMM
This profile configures the pipeline to use DeepTMHMM for protein topology prediction.
```sh
nextflow run PRESERVE.nf -p use_DeepTMHMM
```
DeepTMHMM can identify the following types of proteins:\
1. GLOB: globular proteins
2. SP+GLOB: globular proteins with signal peptides
3. BETA: transmembrane proteins with a beta-barrel fold
4. TM: transmembrane proteins with an alpha-helical fold
5. SP+TM: transmembrane proteins with an alpha-helical fold and a signal peptide\
In this case the default parameters include all three types of transmembrane proteins and exclude the two types of globular proteins. This filter can also be customized:
```sh
params.protein_filter_include = [string to include]
params.protein_filter_exclude = [string to exclude]
```
#### User specified set
This profile uses neither tool and instead the user can specify a list of proteins to be selected:
```sh
nextflow run PRESERVE.nf -p provide_Set
```
If this option is used the user can input their subset as follows:
```sh
params.protein_subset = [txt with list of proteins]
```
The string filtering can also be applied to this set, but is by default configured to accept all entries in the list.
```sh
params.protein_filter_include = [string to include]
params.protein_filter_exclude = [string to exclude]
```
### Important parameters
It is possible to set the parameters used by the tools in PRESERVE directly from the command line when executing PRESERVE. In this way the clustering and comparison steps can be configured to be more or less lenient.
#### Sequence clustering:
In the sequence clustering step, the required coverage and sequence identity for two proteins to be clustered together by MMSeqs2 can be set. They are 0.8 each by default:
```sh
nextflow run PRESERVE.nf --default_id_mmseqs2 [number between 0 and 1] --default_cov_mmseqs2 [number between 0 and 1]
```
#### UniRef query
For the uniref query, the sequence similarity threshold at which a Uniref structure will be used (if available) can be set. It is set to 0.95 by default:
```sh
nextflow run PRESERVE.nf --identity_requrement [number between 0 and 1]
```
#### Structure clustering
In the structure clustering step the necessary TM-score and coverage at which proteins can be clustered together by foldseek can be set. They are also 0.8 normally:
```sh
nextflow run PRESERVE.nf --default_tm [number between 0 and 1] --default_cov [number between 0 and 1]
```


