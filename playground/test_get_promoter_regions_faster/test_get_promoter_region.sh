python /ceph/ibmi/it/projects/CMFI/Analysis/24_07_24_Nextflow_Pipelines/from_PDBs_to_homologs/bin/get_promoter_regions.py \
    -g /ceph/ibmi/it/projects/CMFI/Analysis/24_07_24_Nextflow_Pipelines/from_PDBs_to_homologs/results_all_samples_new_promoterDB_longer_tests/ExpandFoldseek/putative_homologs_foldseek.txt \
    --metadata /ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/metadata/geneID_toSamples.txt \
    -fastas /ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/fastas \
    -gffs /ceph/ibmi/it/projects/CMFI/Data/DATA_PIPELINE/GFFs \
    -d 50 \
    -i 10 \
    -op /ceph/ibmi/it/projects/CMFI/Analysis/24_07_24_Nextflow_Pipelines/from_PDBs_to_homologs/results_all_samples_new_promoterDB_longer_tests/reduced_operons/all_reduced_operons_distance_150_no_suffix.txt \
    -o test.txt