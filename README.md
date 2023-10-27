# ExonCalculator

This repository contains a shell script that allows you to extract information from the NCBI RefSeq table in the USCS database using the NM accession numbers of the gene/transcript of interest. With this script, you can retrieve the following information: 

* Chromosome
* Transcription start/end position
* Coding sequencing (CDS) start/end position
* Number of exons
* Exon start/end positions
* Exon length (bp)

The schema for the NCBI RefSeq table in USCS can be found [here](https://genome.ucsc.edu/cgi-bin/hgTables?db=hg19&hgta_group=genes&hgta_track=refSeqComposite&hgta_table=ncbiRefSeqSelect&hgta_doSchema=describe+table+schema).

Please note that the results generated by this code were utilized as part of ongoing projects at the Hospital for Sick Children (SickKids Hospital) by a student in the Costain lab.

To use this code, follow the instructions below:

### Installation

1. For macOS, you can download and install MySQL using Homebrew. Open the terminal and execute the following command:
`brew install mysql`

This will install MySQL on your macOS system. 
For Windows, you can visit the [MySQL website](https://dev.mysql.com/downloads/windows/installer/) to downaload the MySQL Installer. The website provides detailed instructions on how to procees with the installation ona Windows OS. 

2. Download the all shell script files including: ExonCalculator.sh, exon_length.sh, CDSfinder.sh 

### Usage

Prepare input file with NM accession numbers of genes of interest and save in a plain text file named "transcript_ids.txt", following the same format as the example file. 

Open the terminal and navigate to the directory where the shell script and the input file are located. 

In the terminal, execute the following commands:

`sh -c "$(wget -q https://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"`

`export PATH=${HOME}/edirect:${PATH}`

Execute this command to run the program: 

`./ExonCalculator.sh`

The script will process the data, generate results, and save them in an output file named "ExonCalculator_output.csv".

Details of the columns of the output file: 

Column       | Description
-------------| ----------------------------------------------------------------------------
transcript_id| Name of the gene (usually NM number in the input file)
CDS_start    | Coding region start (or end position for - strand)
CDS_end      | Coding region end (or start position for - strand)
chrom        | Reference sequence chromosome 
strand       | Forward (+) or reverse (-) strand 
exonCount    | Number of exons 
exonStarts   | Semicolon separated exon start positions (or end positions for - strand)
exonEnds     | Semicolon separated exon end positions (or start positions for - strand)
exonLength   | Semicolon separated length of exons in bp 
exonFrames   | Exon frame {0,1,2}, or -1 if no frame for exon

### Contributing
Contributions to this repository are welcome. If you find any issues or have suggestions for improvement, please open an issue.

### Contact

Bushra Haque: bushra.haque@sickkids.ca

### License
This project is licensed under the MIT License.
