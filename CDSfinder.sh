#!/bin/bash

# Define the input file containing NM accession numbers
input_file="transcript_ids.txt"

# Define the output file where the CDS information will be stored
output_file="CDS_output.csv"

# Write the header to output file
echo "transcript_id,output" > "$output_file"

# Run the esearch and efetch commands and store the output in a temporary file
temp_output=$(esearch -db nucleotide -query "$(cat "$input_file" | tr '\n' ' ')" | efetch -format gb | awk '/CDS/ {print $2}' | grep -E -o '[0-9]+\.\.[0-9]+' | grep -v '^$')

# Combine the data and write to the output file
paste <(cat "$input_file") <(echo "$temp_output") | tr '\t' ',' >> "$output_file"

# Print a message indicating that the operation is complete
echo "CDS information saved to $output_file"

# Use the output column in the output file to extract the two values and calculate the difference
awk -F',' 'BEGIN {print "transcript_id,CDS_start,CDS_end,CDS_length"} NR>1 {gsub(/\.\./,",",$2); split($2,a,","); len=a[2]-a[1]; print $1 "," a[1] "," a[2] "," len}' "$output_file" > temp_output.csv

# Overwrite the original output file with the new one containing the updated columns
mv temp_output.csv "$output_file"

# Print a message indicating that the columns have been updated
echo "CDS length calculated and updated in $output_file"

