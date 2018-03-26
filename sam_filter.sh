#!/bin/sh

sam_filter () {

#making bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)

#Just some start-up text for future reference
echo
echo "=============================================================="
echo "${bold}Now beginning SAM filtering using: ${normal}"
samtools --version
echo "${bold}All outputs will be given as with the extension *_filtered.bam ${normal}"
echo

#Begin the for loop for every "file" in ./aligned_reads directory.
for file in ./aligned_reads/*_al.sam
do
tmp=${file##*/}
basename=${tmp%%"_al.sam"}
echo "${bold}Starting ${basename} at $(date +%T)${normal}"

#Get the start time from the built-in BASH timer (SECONDS)
start=$SECONDS

#Print the number of input reads for ${file} and filter out multiple-aligning reads. Output to BAM
echo "${basename} input reads:"
samtools view ${file} | wc -l
samtools view -h  ${file} | grep -e ^@ -e NH:i:1 | samtools view -bh -o ./aligned_reads/${basename}_filtered.bam

sleep 2

#Report number of output reads and the duration of the filtering
echo "${basename} output reads:"
samtools view ./aligned_reads/${basename}_filtered.bam | wc -l
duration=$((SECONDS- start))

#echo "Finished with ${file} at ${stop}"
echo "Filtering ${basename} took $(($duration / 60)) minutes and $(($duration%60)) seconds"
echo "--------------------------------------------------------------"
echo "\n"

done

echo "Filtering is finished for all input files"


}

sam_filter


