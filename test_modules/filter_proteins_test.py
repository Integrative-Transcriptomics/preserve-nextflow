# Read file names from the Command line arguments, the faa file has to be parsed first, the topologies second, and the third argument should be the string that we search for.
import sys
name_faa = sys.argv[1]
name_3line = sys.argv[2]
filter_string = sys.argv[3]

# Read the faa file from the bakta output into python.
# Lines 2n (0,2,4,6,etc) are the names and ids of the sequences.
# Lines 2n+1 (1,3,5,etc) are the sequences themselves.
df_faa = open(name_faa, "r")
Lines_faa = df_faa.readlines()
test_faa = Lines_faa[0:6]
#print(Lines_faa[0:3])

# Read the 3line file from the deepTMHMM output into python.
# Lines 3n (0,3,6,9,etc) are the ids and classes of the sequences.
# Lines 3n+1 (1,4,7,etc) are the sequences themselves.
# Lines 3n+2 (2,5,8,etc) are the sequences themselves.
df_3line = open(name_3line, "r")
Lines_3line = df_3line.readlines()
test_3line = Lines_3line[0:9]
#print(Lines_3line[0:3])

# Iterate through a list and check whether a string is contained therein and whether the current index is divisible by 3, if so the index of the line is added to a list.
# Case Sensitive!
def search_3line(file, string):
    filtered_indeces = []
    for x in file:
        if (string in x) and (file.index(x) % 3 == 0):
            filtered_indeces.append(file.index(x))
    return filtered_indeces

# Adapt the indeces from 3line format to faa, because each entry has 3 lines in 3line and only 2 in faa
def translate_indeces(list):
    translated_indeces = []
    for x in list:
        if x == 0:
            translated_indeces.append(x)
        else:
            translated_indeces.append(x/3*2)
    return translated_indeces 

# Writes a new fasta file containing all lines from the initial file that are in the list and the line directly after.
def filter_fasta(file, list):
    new_file = open("filtered_proteins.fasta", "w")
    for x in file:
        if file.index(x) in list:
            new_file.write(x)
        if file.index(x)-1 in list:
            new_file.write(x)

    new_file.close
            



test_file = ["eins","zwei","drei"]
test_result1 = search_3line(Lines_3line, filter_string)
test_result2 = translate_indeces(test_result1)
#print(test_result2)
filter_fasta(Lines_faa, test_result2)
#print(test_faa)
#print(test_3line)
#print(name_faa)