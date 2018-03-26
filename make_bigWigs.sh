#! /bin/sh

make_bigWigs () {

#making bold, normal text and also starting a file counter
bold=$(tput bold)
normal=$(tput sgr0)
fileTotal=$(ls ./aligned_reads/*_filtered.bam|wc -l)
counter=0

#Just some start-up text for future reference
echo
echo "======================================================"
echo "${bold}Now beginning to make bedGraphs and bigWigs using: ${normal}"
samtools --version
echo
echo "${bold}Note that the following files will be made for all ${fileTotal} filtered BAM files:${normal} "
echo "Exon-split bedgraphs: 		*_split.bedgraph" 
echo "Exon-split, sorted bedgraphs: 	*_split_sorted.bedgraph" 
echo "Exon-split bigWigs: 		*_split.bw" 
echo "Exon-joined bedgraphs: 		*_join.bedgraph"
echo "Exon-joined, sorted bedgraphs: 	*_join_sorted.bedgraph" 
echo "Exon-joined bigWigs: 		*_join.bw"  
echo "\n----------------------------------------------------"

#Assuming you are in the project directory, makes a new directory for output files. Will overwrite any existing "/bigWigs" directories!!
mkdir -p ./bigWigs
cd ./bigWigs

#Starts a for loop for the *_filtered.bam files in the aligned_reads directory
for file in ../aligned_reads/*_filtered.bam

do
tmp=${file##*/}
basename=${tmp%%"_filtered.bam"}

#Adds 1 to the counter and announces the start of making bigWigs for the current file
counter=$((counter+1))
echo "${bold}Starting to make bigWigs for ${basename}_filtered.bam${normal}"
date
echo

#Makes a GenomeCov begraph and then bigWig for the file, but splits the exon junctions
echo "${bold}Making an exon-split GenomeCov bedgraph for ${basename}${normal}"
samtools sort ${file} -O bam |bedtools genomecov -ibam stdin -bga -split > ${basename}_split.bedgraph
echo "${basename}_split.bedgraph is finished"
sort -k1,1 -k2,2n ${basename}_split.bedgraph > ${basename}_split_sorted.bedgraph
echo "${basename}_split_sorted.bedgraph is finished"
bedGraphToBigWig ${basename}_split_sorted.bedgraph http://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes ${basename}_split.bw

echo "Finished making ${basename}_split.bw "
echo

#Makes a GenomeCov bedgraph and then the bigWig for the file, but does not split the exons
echo "${bold}Making an exon-joined GenomeCov bedgraph for ${basename}${normal}"
samtools sort ${file} -O bam |bedtools genomecov -ibam stdin -bga > ${basename}_join.bedgraph
echo "${basename}_join.bedgraph is finished"
sort -k1,1 -k2,2n ${basename}_join.bedgraph > ${basename}_join_sorted.bedgraph
echo "${basename}_join_sorted.bedgraph is finished"
bedGraphToBigWig ${basename}_join_sorted.bedgraph http://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes ${basename}_join.bw

echo "Finished making ${basename}_join.bw"
echo "${bold}I have finished making bigWigs for ${bold}${counter}/${fileTotal}${normal} BAM datasets.${normal}"
date
echo "\n----------------------------------------------------"
echo

done
echo "All done making bigWigs!"

}


make_bigWigs
