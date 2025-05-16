# Read a number of files 
import sys

# Select only the filenames from the console input
output_name = sys.argv[1]
filenames = sys.argv[2:]

with open(output_name, "w") as outfile:
    for names in filenames:
        with open(names) as infile:
            outfile.write(infile.read())
  












