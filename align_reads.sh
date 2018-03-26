#! /bin/sh

## making bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)

## make new directory for aligned reads
mkdir ./aligned_reads

## get list of input files
files=./trimmed_reads/*.fastq


## hisat2 alignment function
hisat2_align () {

echo "==============================================================================="
## report hisat2 version
echo "${bold}Now beginning read alignment using: ${normal}"
hisat2 --version
echo ""

## list input files
echo "${bold}input files: ${normal}"
ls -1 ${files}
echo ""

## list non-default parameters used for alignment
echo "${bold}the following non-default parameters were used:${normal}"
echo "-k 2 (for reads aligning to more than one location, only report the first two alignments found)"
echo ""

## list genome version used for alignment

## loop over all the files in the current directory ending in "_trimmed.fastq"
for file in ${files}

do
## extract the basename of the file by taking everything up to "_filtered.bam"
tmp=${file##*/}
basename=${tmp%%"_trimmed.fastq"}


echo ${file}
date

hisat2 -k 2 -x /home/harrison/Desktop/Documents/CRY2-ZLD/Genome_indexes/dm6/dm6 -U /home/harrison/Desktop/Documents/CRY2-ZLD/Concatenated_FASTQ_file/${file}_trim.fastq.gz -S ${file}_al.sam --un ${file}_un.sam --summary-file ${file}_summary.txt

date
echo "\n"
done

}

##bowtie2 alignment function
bowtie2_align () {
echo "==============================================================================="
echo "${bold}Now beginning read alignment using: ${normal}"
bowtie2 --version

echo "${bold}input files: ${normal}"
ls -1 files



}
