#!/bin/bash

set -euo pipefail

input_file="transcript_ids.txt"
merged_output_filename="${PWD}/ExonCalculator_output.csv"

OPTSTRING="i:o:"

while getopts ${OPTSTRING} opt; do
  case ${opt} in
    i)
      input_file=${OPTARG};;
    o)
      merged_output_filename=${OPTARG};;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1;;
  esac
done

export input_file

intermediate_dir="$(dirname "${merged_output_filename}")"
cds_output_filename="${intermediate_dir}/CDS_output.csv"
exon_length_output_filename="${intermediate_dir}/ExonLength_output"

# Run Script 1 and Script 2
./CDSfinder.sh "${cds_output_filename}"
./exon_length.sh "${exon_length_output_filename}"

# Merge the output files

echo "transcript_id,CDS_start,CDS_end,CDS_length,bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,gene,cdsStartStat,cdsEndStat,exonFrames,exonStarts,exonEnds,exonLengths" > "$merged_output_filename"

# Merge the files side by side, skipping the header lines
paste -d ',' <(tail -n +2 "$cds_output_filename") <(tail -n +2 "$exon_length_output_filename") >> "$merged_output_filename"

# Delete columns named: bin, name, cdsStart, cdsEnd, score, cdsStartStat, cdsEndStat from the merged output file
awk 'BEGIN {FS=",";OFS=","} {print $1, $2, $3, $4, $7, $8, $15, $13, $19, $20, $21, $18}' "$merged_output_filename" > temp_file && mv temp_file "$merged_output_filename"

echo "Merged output saved to $merged_output_filename. ExonCalculator job finished."
