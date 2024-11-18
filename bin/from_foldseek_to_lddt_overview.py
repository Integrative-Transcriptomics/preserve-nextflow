import pandas as pd

def read_foldseek(path):
    foldseek = pd.read_csv(path, sep='\t', header=None)
    # set column names
    foldseek.columns = ["query","target","fident","alnlen","mismatch","gapopen","qstart","qend","tstart","tend","evalue","bits","prob","lddt","alntmscore"]
    # for query remove everything before the first underscore
    foldseek["query"] = foldseek["query"].str.split("_").str[1]
    foldseek["query"] = foldseek["query"].str.split(".").str[0]

    # for target remove everything after _unrelaxed
    foldseek["target"] = foldseek["target"].str.split("_unrelaxed").str[0]
    foldseek["target"] = foldseek["target"].str.split(".").str[0]
    return foldseek

def adapt_foldseek(df): 
    # keep query, target, lddt
    df = df[["query","target","lddt"]]
    # aggregate by target and set query to be a column with the corresponding lddt value
    df = df.pivot(index="target", columns="query", values="lddt")
    return df

def main():
    path_input = "/ceph/ibmi/it/projects/CMFI/Analysis/24_07_24_Nextflow_Pipelines/from_PDBs_to_homologs/results_all_samples_new_promoterDB_longer/Foldseek/sorted_CorynebacteriaVsStaphAureus.tsv"
    foldseek = read_foldseek(path_input)
    foldseek = adapt_foldseek(foldseek)
    # adapt output path to be the same as the input path but with _adapted appended
    path_output = path_input.split(".")[0] + "_adapted.tsv"
    foldseek.to_csv(path_output, sep="\t")

if __name__ == "__main__":
    main()
    
