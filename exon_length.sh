#!/bin/bash

# Database connection details
host="genome-mysql.cse.ucsc.edu"
user="genome"
database="hg38"

# Input file containing NM numbers
input_file="transcript_ids.txt"

# Output file name
output_file="ExonLength_output.csv"

# Remove the existing output file if it exists
rm -f "$output_file"

# Write the header to the output file
echo "bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,gene,cdsStartStat,cdsEndStat,exonFrames,exonStarts,exonEnds,exonLengths" > "$output_file"

# Establish a persistent MySQL connection
mysql -h "${host}" -u "${user}" -D "${database}" <<EOF |
SET SESSION wait_timeout = 3600;  -- Set the timeout value to keep the connection alive (e.g., 1 hour)
SET SESSION interactive_timeout = 3600;
SELECT 1;  -- Ping the server to keep the connection alive
EOF

# Read NM numbers from the input file and process each NM number
while IFS= read -r nm_number || [[ -n "$nm_number" ]]; do
  # Skip non-NM number entries
  if [[ -z $nm_number || $nm_number != NM_* ]]; then
    continue
  fi

  # Execute the MySQL query and append the results to the output file
  mysql -h "${host}" -u "${user}" -D "${database}" -e "SELECT bin,name,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,score,name2,cdsStartStat,cdsEndStat, GROUP_CONCAT(DISTINCT exonFrames SEPARATOR ';'), GROUP_CONCAT(DISTINCT exonStarts SEPARATOR ';'), GROUP_CONCAT(DISTINCT exonEnds SEPARATOR ';') FROM refGene WHERE name='${nm_number}' GROUP BY name" -N | awk -F'\t' 'BEGIN{OFS=","} {gsub(/,/,";", $14); gsub(/,/,";", $15); gsub(/,/,";", $16); gsub(/; /,";", $15); gsub(/; /,";", $16); gsub(/ /,"", $15); gsub(/ /,"", $16); split($14, exonFramesArr, ";"); split($15, exonStartsArr, ";"); split($16, exonEndsArr, ";"); exonLengths=""; exonStarts=""; exonEnds=""; strand=$4; for (i=1; i<=length(exonFramesArr); i++) { lengthDiff = exonEndsArr[i] - exonStartsArr[i]; if (exonStarts != "") { exonStarts = exonStarts ";" } exonStarts = exonStarts exonStartsArr[i]; if (exonEnds != "") { exonEnds = exonEnds ";" } exonEnds = exonEnds exonEndsArr[i]; if (exonLengths != "") { exonLengths = exonLengths ";" } exonLengths = exonLengths lengthDiff; } $14=$14; $15=exonStarts; $16=exonEnds; $17=exonLengths; if (strand == "-") { split(exonStarts, exonStartsArr, ";"); split(exonEnds, exonEndsArr, ";"); exonStarts=""; exonEnds=""; for (i=length(exonStartsArr); i>=1; i--) { if (exonStarts != "") { exonStarts = exonStarts ";" } exonStarts = exonStarts exonStartsArr[i]; if (exonEnds != "") { exonEnds = exonEnds ";" } exonEnds = exonEnds exonEndsArr[i]; } $15=exonStarts; $16=exonEnds; } print}' | awk 'BEGIN{FS=OFS=","} {sub(/;$/,"",$15); sub(/;$/,"",$16); print $0}' | awk -F, -v OFS=, '{
    if ($4 == "-") {
        split($15, starts, ";");
        split($16, ends, ";");
        split($17, lengths, ";");
        rev_starts="";
        rev_ends="";
        rev_lengths="";
        for (i = length(starts); i >= 1; i--) {
            if (rev_starts != "") {
                rev_starts = rev_starts ";";
            }
            if (rev_ends != "") {
                rev_ends = rev_ends ";";
            }
            if (rev_lengths != "") {
                rev_lengths = rev_lengths ";";
            }
            rev_starts = rev_starts starts[i];
            rev_ends = rev_ends ends[i];
            rev_lengths = rev_lengths lengths[i];
        }
        $15=rev_starts;
        $16=rev_ends;
        $17=rev_lengths;
    }
    print
}' | awk -F, -v OFS=, '{
    if ($17 ~ /^0;/) {
        sub(/^0;/, "", $17);
    }
    if ($17 ~ /;0$/) {
        sub(/;0$/, "", $17);
    }
    print
}' >> "$output_file"
done < "$input_file"

# Print a message indicating that the columns have been updated
echo "Exon lengths have been calculated and updated in $output_file"
