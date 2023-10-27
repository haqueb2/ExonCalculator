#!/bin/bash

# Define the input file containing NM accession numbers for both scripts
input_file="transcript_ids.txt"

# Run Script 1 and Script 2
./CDSfinder.sh
./exon_length.sh

# Merge the output files
merged_output_file="ExonCalculator_output.csv"
echo "transcript_id,CDS_start,CDS_end,CDS_length,bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,gene,cdsStartStat,cdsEndStat,exonFrames,exonStarts,exonEnds,exonLengths" > "$merged_output_file"

# Merge the files side by side, skipping the header lines
paste -d ',' <(tail -n +2 CDS_output.csv) <(tail -n +2 ExonLength_output.csv) >> "$merged_output_file"

# Delete columns named: bin, name, cdsStart, cdsEnd, score, cdsStartStat, cdsEndStat from the merged output file
awk 'BEGIN {FS=",";OFS=","} {print $1, $2, $3, $4, $7, $8, $15, $13, $19, $20, $21, $18}' "$merged_output_file" > temp_file && mv temp_file "$merged_output_file"

echo "Merged output saved to $merged_output_file. ExonCalculator job finished."
