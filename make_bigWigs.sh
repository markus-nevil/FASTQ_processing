#! /bin/sh

make_bigWigs () {

#making bold, normal text and also starting a file counter
bold=$(tput bold)
normal=$(tput sgr0)
fileTotal=$(ls ./aligned_reads/*_filtered.bam|wc -l)
counter=0

#Seeing if there are more than one file, for grammar reasons later on
if [ "$fileTotal" -gt "1" ]; then
plural="s"
else
plural=""
fi

#Assuming you are in the project directory, makes a new directory for output files. Will overwrite any existing "/bigWigs" directories!!
mkdir -p ./bigWigs
cd ./bigWigs


## Checks to see if the data are RNA-seq ($1 = TRUE) or genome-seq ($1 = FALSE)
if [ "$1" = "RNA" ];
then
#Just some start-up text for future reference
echo
echo "======================================================"
echo "${bold}Now beginning to make bedGraphs and bigWigs using: ${normal}"
samtools --version
echo
echo "${bold}Note that the following files will be made for all ${fileTotal} filtered BAM file$plural:${normal} "
echo "Exon-split bedgraphs: 		*_split.bedgraph" 
echo "Exon-split, sorted bedgraphs: 	*_split_sorted.bedgraph" 
echo "Exon-split bigWigs: 		*_split.bw" 
echo "Exon-joined bedgraphs: 		*_join.bedgraph"
echo "Exon-joined, sorted bedgraphs: 	*_join_sorted.bedgraph" 
echo "Exon-joined bigWigs: 		*_join.bw"  
echo "\n----------------------------------------------------"

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

##If the data are not RNA-seq, the script begins here in order to skip the exon-splitting
else

#Just some start-up text for future reference
echo
echo "======================================================"
echo "${bold}Now beginning to make bedGraphs and bigWigs using: ${normal}"
samtools --version
echo
echo "${bold}Note that the following files will be made for all ${fileTotal} filtered BAM file$plural:${normal} "
echo "Bedgraphs: 		*.bedgraph" 
echo "Sorted bedgraphs: 	*_sorted.bedgraph" 
echo "bigWigs: 		*.bw" 
echo "\n----------------------------------------------------"

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

#Makes a GenomeCov bedgraph and then the bigWig for the file
echo "${bold}Making a GenomeCov bedgraph for ${basename}${normal}"
samtools sort ${file} -O bam |bedtools genomecov -ibam stdin -bga > ${basename}.bedgraph
echo "${basename}.bedgraph is finished"
sort -k1,1 -k2,2n ${basename}.bedgraph > ${basename}_sorted.bedgraph
echo "${basename}_sorted.bedgraph is finished"
bedGraphToBigWig ${basename}_sorted.bedgraph http://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes ${basename}.bw

echo "Finished making ${basename}.bw"
echo "${bold}I have finished making bigWigs for ${bold}${counter}/${fileTotal}${normal} BAM datasets.${normal}"
date
echo "\n----------------------------------------------------"
echo

done
echo "All done making bigWigs!"
fi

}
