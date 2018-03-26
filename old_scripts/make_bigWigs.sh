#! /bin/sh

#making bold, normal text and also starting a file counter!
bold=$(tput bold)
normal=$(tput sgr0)
fileTotal=$(ls *_filtered.bam|wc -l)
counter=0

echo "\n"

#Starts a for loop for the files in current directory (note: Only with these names)
for file in CRY_10_1_S3   CRY_NL_3_S17 CRY_10_2_S4   CRY_NL_4_S18 CRY_10_4_S12  WT_10_1_S1 CRY_13_1_S7   WT_10_2_S2 CRY_13_2_S8   WT_10_4_S11 CRY_13_3_S15 WT_13_1_S5 CRY_13_4_S16  WT_13_2_S6 CRY_NL_1_S9  WT_13_3_S13 CRY_NL_2_S10  WT_13_4_S14

do

#Adds 1 to the counter and announces the start of making bigWigs for the current file
counter=$((counter+1))
echo "${bold}Starting to make bigWigs for ${file}_filtered.bam"
date
echo "\n"

#Makes a GenomeCov begraph and then bigWig for the file, but splits the exon junctions
echo "${bold}Making an exon-split GenomeCov bedgraph for ${file}${normal}"
samtools sort ${file}_filtered.bam -O bam |bedtools genomecov -ibam stdin -bga -split > ${file}_split.bedgraph
echo "${file}_split.bedgraph is finished"
sort -k1,1 -k2,2n ${file}_split.bedgraph > ${file}_split_sorted.bedgraph
echo "${file}_split_sorted.bedgraph is finished"
bedGraphToBigWig ${file}_split_sorted.bedgraph http://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes ${file}_split.bw

echo "${bold}Finished making ${file}_split.bw ${normal}"
echo "\n"

#Makes a GenomeCov bedgraph and then the bigWig for the file, but does not split the exons
echo "${bold}Making an exon-joined GenomeCov bedgraph for ${file}${normal}"
samtools sort ${file}_filtered.bam -O bam |bedtools genomecov -ibam stdin -bga > ${file}_join.bedgraph
echo "${file}_join.bedgraph is finished"
sort -k1,1 -k2,2n ${file}_join.bedgraph > ${file}_join_sorted.bedgraph
echo "${file}_join_sorted.bedgraph is finished"
bedGraphToBigWig ${file}_join_sorted.bedgraph http://hgdownload.cse.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes ${file}_join.bw

echo "${bold}Finished making ${file}_join.bw${normal}"
echo "I have finished making bigWigs for ${bold}${counter}/${fileTotal}${normal} BAM datasets."
echo "----------------------------------------------"


date
echo "\n"
done

echo "All done!"


