# ExonCalculator

This repository contains a shell script that allows you to extract information from the NCBI RefSeq table in the USCS database using the NM accession numbers of the gene/transcript of interest. With this script, you can retrieve the following information: 

* Chromosome
* Transcription start/end position
* Coding sequencing (CDS) start/end position
* Number of exons
* Exon start/end positions
* Exon length (bp)

The schema for the NCBI RefSeq table in USCS can be found here: https://genome.ucsc.edu/cgi-bin/hgTables?db=hg19&hgta_group=genes&hgta_track=refSeqComposite&hgta_table=ncbiRefSeqSelect&hgta_doSchema=describe+table+schema

Please note that the results generated by this code were utilized as part of ongoing projects at the Hospital for Sick Children (SickKids Hospital) by a student in the Costain lab.

To use this code, follow the instructions below:

### Prerequisites

- Terminal access
-  MySQL

### Installation

1. For MacOS, download mysql using Homebrew: `brew install mysql` 
2. Download the shell script file: exon_length.sh

### Usage
Open the terminal and navigate to the directory where the shell script and the input file "nm_numbers.txt" are located.

Ensure that the "nm_numbers.txt" file contains the NM numbers of the genes you're interested in, following the same format as the provided in the example file called "nm_numbers.txt".

In the terminal, execute the following command:

`./exon_length.sh`

The script will process the data, generate results, and save them in an Excel file named "output.csv".

### Contributing
Contributions to this repository are welcome. If you find any issues or have suggestions for improvement, please open an issue or submit a pull request.

### Contact
Bushra Haque 
bushra.haque@sickkids.ca

### License
This project is licensed under the MIT License.
