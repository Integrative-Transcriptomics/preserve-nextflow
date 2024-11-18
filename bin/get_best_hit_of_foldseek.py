import argparse
import pandas as pd
def read_foldseek(path): 
    df = pd.read_csv(path, sep='\t')
    # set column lddt to float
    df['lddt'] = df['lddt'].astype(float)
    return df

def create_groups(df, group_col):
    groups = df.groupby(group_col)
    print(groups.head())
    return groups

def get_best_hit(groups, score_col):
    best_hits_idx = groups[score_col].idxmax()
    return best_hits_idx

def write_best_hits(best_hits, outpath):
    best_hits.to_csv(outpath, sep='\t', index=False)

def read_species_mapping(path):
    df = pd.read_csv(path, sep=',')
    # set column GeneID to key and Organism (MALDI) to value
    species = df.set_index('geneID')['Organism (MALDI)'].to_dict()
    return species

def main():
    parser = argparse.ArgumentParser(description='Get the best hit of each group in a FoldSeek output file')
    parser.add_argument('foldseek', type=str, help='Path to the FoldSeek output file')
    parser.add_argument('group_col', type=str, help='Column to group by')
    parser.add_argument('sort_col', type=str, help='Column to sort by')
    parser.add_argument('score_col', type=str, help='Column to get the best hit by')
    parser.add_argument('outpath', type=str, help='Path to the output file')
    parser.add_argument('species', type=str, help='Species mapping')
    args = parser.parse_args()

    df = read_foldseek(args.foldseek)
    groups = create_groups(df, args.group_col)
    best_hits = get_best_hit(groups, args.score_col)
    # sort best_hits by query name
    subset_df = df.loc[best_hits]
    subset_df_sorted = subset_df.sort_values(by=args.sort_col)
    subset_df_sorted["geneID"] = subset_df_sorted["target"].str.split("_").str[0]
    species = read_species_mapping(args.species)
    subset_df_sorted['Organism (MALDI)'] = subset_df_sorted['geneID'].map(species)
    write_best_hits(subset_df_sorted, args.outpath)

if __name__ == '__main__':
    main()