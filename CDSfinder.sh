#!/bin/bash
set -uo pipefail

# Reads transcript IDs produced by exon_length.sh so that IDs always match
input_file="output/ExonLength_output.csv"
output_file="output/CDS_output.csv"

mkdir -p output

echo "transcript_id,mane_status,CDS_start,CDS_end,CDS_length" > "$output_file"

while IFS=',' read -r transcript_id rest; do

  # Fetch the full GenBank record once; extract MANE status (from KEYWORDS) and
  # CDS position in a single awk pass to avoid fetching twice.
  # </dev/null prevents esearch from consuming the while-loop's stdin.
  # Output format: "mane_status<TAB>cds_range"
  result=$(esearch -db nucleotide -query "${transcript_id}[ACCN]" </dev/null 2>/dev/null | \
           efetch -format gb 2>/dev/null | \
           awk '
             /^KEYWORDS/    { kw = $0 }
             /^  /          { if (kw != "") kw = kw $0 }
             /^ {5}CDS/ {
               mane = ""
               if (kw ~ /MANE Select/)             mane = "MANE Select"
               else if (kw ~ /MANE Plus Clinical/) mane = "MANE Plus Clinical"
               match($0, /[0-9]+\.\.[0-9]+/)
               if (RSTART) { print mane "\t" substr($0, RSTART, RLENGTH); exit }
             }
           ')

  IFS=$'\t' read -r mane_status cds <<< "$result"
  mane_status="${mane_status:-}"
  cds="${cds:-}"

  # Skip transcripts that are not MANE Select or MANE Plus Clinical
  if [ -z "$mane_status" ]; then
    continue
  fi

  if [ -n "$cds" ]; then
    start=$(echo "$cds" | grep -Eo '^[0-9]+')
    end=$(echo   "$cds" | grep -Eo '[0-9]+$')
    len=$((end - start))
    echo "${transcript_id},${mane_status},${start},${end},${len}"
  else
    echo "${transcript_id},${mane_status},,,"
  fi

done < <(tail -n +2 "$input_file") >> "$output_file"

echo "CDS data saved to $output_file (MANE Select / MANE Plus Clinical only)"

