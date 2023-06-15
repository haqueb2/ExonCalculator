#!/bin/bash

# Database connection details
host="genome-mysql.cse.ucsc.edu"
user="genome"
database="hg19"

# Input file containing NM numbers
input_file="nm_numbers.txt"

# Output file name
output_file="combined_output.csv"

# Remove the existing output file if it exists
rm -f "$output_file"

# Write the header to the output file
echo "bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,gene,cdsStartStat,cdsEndStat,exonFrames,exonStarts,exonEnds,exonLengths" > "$output_file"

# Read NM numbers from the input file and process each NM number
while IFS= read -r nm_number; do
  # Skip non-NM number entries
  if [[ $nm_number != NM_* ]]; then
    continue
  fi

  # Execute the MySQL query and append the results to the output file
  mysql -h "${host}" -u "${user}" -D "${database}" -e "SELECT bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,name2,cdsStartStat,cdsEndStat, GROUP_CONCAT(DISTINCT exonFrames SEPARATOR ';'), GROUP_CONCAT(DISTINCT exonStarts SEPARATOR ';'), GROUP_CONCAT(DISTINCT exonEnds SEPARATOR ';') FROM refGene WHERE name='${nm_number}' GROUP BY name" -N | awk -F'\t' 'BEGIN{OFS=","} {gsub(/,/,";", $14); gsub(/,/,";", $15); gsub(/,/,";", $16); split($14, exonFramesArr, ";"); split($15, exonStartsArr, ";"); split($16, exonEndsArr, ";"); exonLengths=""; for (i=1; i<=length(exonFramesArr); i++) { lengthDiff = exonEndsArr[i] - exonStartsArr[i]; exonStarts = exonStarts exonStartsArr[i] ";"; exonEnds = exonEnds exonEndsArr[i] ";"; exonLengths = exonLengths lengthDiff ";"; } $14=$14; $15=exonStarts; $16=exonEnds; $17=exonLengths; print}' >> "$output_file"
done < "$input_file"
