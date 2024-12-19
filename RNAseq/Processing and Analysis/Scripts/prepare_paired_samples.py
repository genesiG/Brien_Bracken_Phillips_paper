import os

# Directory containing your raw data files
data_directory = "raw_data"

# File extension to exclude
custom_extension = ".fastq.gz"  

# Get a list of all files in the directory
file_list = os.listdir(data_directory)

# Filter the list to include only files (not subdirectories)
file_list = [f for f in file_list if os.path.isfile(os.path.join(data_directory, f))]

# Extract sample names from file names while excluding the custom extension
sample_names = [f.replace(custom_extension, "") for f in file_list if f.endswith(custom_extension)]

# Create a dictionary to store sample names and their corresponding paired samples
sample_mapping = {}
for sample_name in sample_names:
    if "_R1" in sample_name:
        paired_sample = sample_name.replace("_R1", "_R2")
        sample_mapping[sample_name] = paired_sample

# Create the paired_samples.txt file
with open("paired_samples.txt", "w") as file:
    # Write the header
    file.write("sample.name\tsample.control\n")
    
    # Write paired samples
    for sample_name, paired_sample in sample_mapping.items():
        file.write(f"{sample_name}\t{paired_sample}\n")

print("paired_samples.txt has been created.")