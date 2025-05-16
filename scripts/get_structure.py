import urllib.request
import sys
import os


def get_structure(uniprot_identifier, protein_id, target_file = None):
    url = "https://alphafold.ebi.ac.uk/files/AF-{}-F1-model_v4.pdb".format(uniprot_identifier)
    if target_file is None:
        #target_file = "./AF-{}-F1-model_v4.pdb".format(uniprot_identifier)
        target_file = "./structure"+protein_id+".pdb".format(uniprot_identifier)
    try:
        response = urllib.request.urlopen(url)
        data = response.read()
        pdb_text = data.decode("utf-8")
        with open(target_file, "w") as tf:
            tf.write(pdb_text)
    except:
        raise Exception("Alphafold structure not available for UniProt id {}.".format(str(uniprot_identifier)))
    
if __name__ == "__main__":

    # Argument 1 = tsv list of the proteins with db references, from find_candidates_test
    reference_list_name = sys.argv[1]

    #os.mkdir("./protein_structures")

    protein_list = []
    with open(reference_list_name) as file:
        for line in file:
            protein_list.append(line.strip().split())

    for i in protein_list[1:]:
        code = i[1][9:]
        name = i[0]
        get_structure(code, name)
    