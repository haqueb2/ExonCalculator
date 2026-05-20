#!/bin/bash
set -uo pipefail

mkdir -p input output

# ── Step 1: Exon structure from UCSC (input/gene_names.txt → output/ExonLength_output.csv) ──
echo "=== Step 1: Fetching exon structure from UCSC ==="
./exon_length.sh

# ── Step 2: mRNA CDS positions from NCBI (output/ExonLength_output.csv → output/CDS_output.csv) ──
echo "=== Step 2: Fetching CDS positions from NCBI ==="
./CDSfinder.sh

# ── Step 3: Join ExonLength and CDS on transcript_id ──
echo "=== Step 3: Joining results on transcript_id ==="

output_file="output/ExonCalculator_output.csv"

# ExonLength columns: 1=transcript_id  2=chrom  3=strand  4=txStart  5=txEnd
#                     6=cdsStart  7=cdsEnd  8=exonCount  9=gene  10=exonFrames
#                     11=exonStarts  12=exonEnds  13=exonLengths
# CDS columns:        1=transcript_id  2=mane_status  3=CDS_start  4=CDS_end  5=CDS_length
# Output order:       transcript_id, gene, mane_status, chrom, strand, txStart, txEnd,
#                     cdsStart, cdsEnd, CDS_start, CDS_end, CDS_length,
#                     exonCount, exonStarts, exonEnds, exonLengths, exonFrames

echo "transcript_id,gene,mane_status,chrom,strand,txStart,txEnd,cdsStart,cdsEnd,CDS_start,CDS_end,CDS_length,exonCount,exonStarts,exonEnds,exonLengths,exonFrames" > "$output_file"

awk -F',' 'BEGIN { OFS="," }
  # Pass 1: load ExonLength data, keyed by transcript_id
  FNR==NR {
    if (FNR > 1)
      exon[$1] = $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS $13
    next
  }
  # Pass 2: join CDS rows against loaded ExonLength data
  FNR > 1 {
    tid = $1
    if (tid in exon) {
      split(exon[tid], e, OFS)
      # e: chrom(1) strand(2) txStart(3) txEnd(4) cdsStart(5) cdsEnd(6)
      #    exonCount(7) gene(8) exonFrames(9) exonStarts(10) exonEnds(11) exonLengths(12)
      print tid, e[8], $2, e[1], e[2], e[3], e[4], e[5], e[6], $3, $4, $5, e[7], e[10], e[11], e[12], e[9]
    }
  }
' output/ExonLength_output.csv output/CDS_output.csv >> "$output_file"

echo "Final output saved to $output_file"
echo "ExonCalculator job finished."
