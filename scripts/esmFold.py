#!/bin/python

if __name__ == "__main__" :

    import argparse

    parser = argparse.ArgumentParser(
        prog="it.esm3-open",
        description="Generate protein structure predictions using the ESM3-open model (on CPU).",
        epilog="Source: https://github.com/evolutionaryscale/esm"
    )
    parser.add_argument(
        "--token",
        help="The 'Hugging Face' token to authenticate access to https://huggingface.co/EvolutionaryScale/esm3-sm-open-v1.",
        type=str,
        default="+++ Huggingface token +++"
    )
    #parser.add_argument(
    #    "--sequence",
    #    help="The protein sequence to generate a structure for.",
    #    type=str,
    #    required=True
    #)
    parser.add_argument(
        "--output",
        help="File pointer to store the generated structure.",
        type=str,
        default="./structure.pdb"
    )
    parser.add_argument(
        "--steps",
        help="The number of steps to run the generation model.",
        type=int,
        default=8
    )
    parser.add_argument(
        "--temperature",
        help="The temperature to run the generation model with.",
        type=float,
        default=0.7
    )
    parser.add_argument(
        "--file",
        help="Fasta file containing protein sequences",
        type=str,
        default="/local_scratch/rack/playground/test_data2/proteins_without_ref.fasta"
    )
    args = parser.parse_args( )

    from huggingface_hub import login
    from esm.models.esm3 import ESM3
    from esm.sdk.api import ESM3InferenceClient, ESMProtein, GenerationConfig
    import os

    # Parse the fasta file and extract the sequences
    file_name = args.file
    #fasta_file = open(file_name, "r")
    #fasta_lines = fasta_file.read().splitlines()
    protein_sequences = []
    protein_ids = []
    
    with open(file_name) as fasta_file:
        fasta_lines = fasta_file.readlines()

    for i in fasta_lines:
        if fasta_lines.index(i) % 2 == 1:
            protein_sequences.append(i.strip())
        else:
            protein_ids.append(i.strip())


    #print("test sequence:")
    #print(len(protein_sequences))
    #print(len(protein_ids))

    # Log in to Hugging Face.
    login(token=args.token)
    # Download the model weights and instantiate the model on your machine.
    # "cpu" may be exchanged with "cuda" - this needs a GPU with Cuda support on the system!
    model: ESM3InferenceClient = ESM3.from_pretrained("esm3-open").to("cpu")
    # Generate a ESMProtein from the specified sequence.
    #protein = ESMProtein(sequence=args.sequence)

    #os.mkdir("./protein_structures")

    for j in protein_sequences:
        counter = protein_sequences.index(j)
        name = protein_ids[counter]
        protein = ESMProtein(sequence=j)
        # Predicted structure for the specified sequence.
        protein = model.generate(protein, GenerationConfig(track="structure", num_steps=args.steps, temperature=args.temperature))
        # Store the predicted structure to local file.
        protein.to_pdb("./structure"+name[1:13]+".pdb")


