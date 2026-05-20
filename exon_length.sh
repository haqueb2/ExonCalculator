#!/bin/bash
set -uo pipefail

# MySQL 8.x client required — MySQL 9.x removed the mysql_native_password plugin used by UCSC
mysql_cmd="/usr/local/Cellar/mysql-client/8.3.0/bin/mysql"
host="genome-mysql.cse.ucsc.edu"
user="genome"
database="hg38"

input_file="input/gene_names.txt"
output_file="output/ExonLength_output.csv"

mkdir -p output

# Write the header — bin, score, cdsStartStat, cdsEndStat are omitted (not needed)
echo "transcript_id,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,exonCount,gene,exonFrames,exonStarts,exonEnds,exonLengths" > "$output_file"

# Build a single IN (...) clause from all gene names — one connection, one query
# tr -d '\r' strips Windows CRLF line endings that would corrupt the SQL string literals
gene_list=$(tr -d '\r' < "$input_file" | awk '{printf "%s'\''%s'\''", (NR==1?"":","), $0}')

"${mysql_cmd}" -h "${host}" -u "${user}" -D "${database}" -N -e \
  "SELECT name, chrom, strand, txStart, txEnd, cdsStart, cdsEnd, exonCount, name2,
   GROUP_CONCAT(DISTINCT exonFrames SEPARATOR ';'),
   GROUP_CONCAT(DISTINCT exonStarts SEPARATOR ';'),
   GROUP_CONCAT(DISTINCT exonEnds   SEPARATOR ';')
   FROM ncbiRefSeqSelect
   WHERE name2 IN (${gene_list}) AND (chrom REGEXP '^chr[0-9]+$' OR chrom = 'chrX')
   GROUP BY name
   ORDER BY name2, name" | \
awk -F'\t' 'BEGIN{OFS=","} {
  gsub(/,/,";", $10); gsub(/,/,";", $11); gsub(/,/,";", $12)
  split($11, starts, ";"); split($12, ends, ";")
  exonLengths=""; exonStarts=""; exonEnds=""
  for (i=1; i<=length(starts); i++) {
    if (starts[i] != "") {
      exonStarts  = exonStarts  starts[i] ";"
      exonEnds    = exonEnds    ends[i]   ";"
      exonLengths = exonLengths (ends[i] - starts[i]) ";"
    }
  }
  print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,exonStarts,exonEnds,exonLengths
}' >> "$output_file"

echo "Exon data saved to $output_file"
