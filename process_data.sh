#! /bin/bash

## making bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)

cat_reads() {
list=()

#extract the basename of the file by taking everything up to the reads-either single end or paired end
for file in ./*.fastq.gz
do
tmp=${file##*/}
basename=${tmp%%_L*}
list+=(${basename})
done

#Take only the unique basenames in list
list=($(echo "${list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo ${list[@]}
mkdir -p ../Concatenated_FASTQ_files

#looping through list of basenames and comparing to every other sample and finding the same sample in a different lane
for sample in ${list[@]}
do 
	echo "I'm going to concatenate ${sample}!"
	#echo ${sample}_L*_R1*.fastq.gz
     	zcat ${sample}_L*_R1*.fastq.gz | gzip > ../Concatenated_FASTQ_files/${sample}_R1_cat.fastq.gz
done
if [ $1 = "RNA" ];
	then
	echo "RNA file!"

for sample in ${list[@]}
do 
	echo "I'm going to concatenate ${sample}!"
	#echo ${sample}_L*_R2*.fastq.gz
     	zcat ${sample}_L*_R2*.fastq.gz | gzip > ../Concatenated_FASTQ_files/${sample}_R2_cat.fastq.gz
done
fi
}

trimmomatic_reads () {
mkdir ../trimmed_reads

for file in ../Concatenated_FASTQ_files/*_cat.fastq.gz

do
#extract the basename of the file by taking everything up to "_cat.fastq.gz"
tmp=${file##*/}
basename=${tmp%%_cat.fastq.gz}

echo ${basename}

#trim
java -jar /home/harrison/Desktop/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog ../trimmed_reads/${basename}_trimlog.txt ../Concatenated_FASTQ_files/${basename}_cat.fastq.gz ../trimmed_reads/${basename}_trim.fastq.gz ILLUMINACLIP:/home/harrison/Desktop/Trimmomatic-0.36/adapters/TruSeq2-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:22 MINLEN:70

done
}

## hisat2 alignment function
hisat2_align () {

## make new directory for aligned reads
mkdir ../aligned_reads

## get list of input files
files=../trimmed_reads/*.fastq.gz

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
basename=${tmp%%_trim.fastq.gz}


echo ${file}
date

hisat2 -k 2 -x /home/harrison/Desktop/Documents/CRY2-ZLD/Genome_indexes/dm6/dm6 -U ../trimmed_reads/${basename}_trim.fastq.gz -S ../aligned_reads/${basename}_al.sam --un ../aligned_reads/${basename}_un.sam --summary-file ../aligned_reads/${basename}_summary.txt

date
echo ""
done

}

##bowtie2 alignment function
bowtie2_align () {

## make new directory for aligned reads
mkdir ../aligned_reads

## get list of input files
files=../trimmed_reads/*.fastq.gz

echo "==============================================================================="
echo "${bold}Now beginning read alignment using: ${normal}"
bowtie2 --version

echo "${bold}input files: ${normal}"
ls -1 files

}

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
for file in ../aligned_reads/*_al.sam
do
tmp=${file##*/}
basename=${tmp%%"_al.sam"}
echo "${bold}Starting ${basename} at $(date +%T)${normal}"

#Get the start time from the built-in BASH timer (SECONDS)
start=$SECONDS

#Print the number of input reads for ${file} and filter out multiple-aligning reads. Output to BAM
echo "${basename} input reads:"
samtools view ${file} | wc -l
samtools view -h  ${file} | grep -e ^@ -e NH:i:1 | samtools view -bh -o ../aligned_reads/${basename}_filtered.bam

#sleep 2

#Report number of output reads and the duration of the filtering
echo "${basename} output reads:"
samtools view ../aligned_reads/${basename}_filtered.bam | wc -l
duration=$((SECONDS- start))

#echo "Finished with ${file} at ${stop}"
echo "Filtering ${basename} took $(($duration / 60)) minutes and $(($duration%60)) seconds"
echo "--------------------------------------------------------------"
echo ""

done

echo "Filtering is finished for all input files"


}
make_bigWigs () {

#making bold, normal text and also starting a file counter
bold=$(tput bold)
normal=$(tput sgr0)
fileTotal=$(ls ../aligned_reads/*_filtered.bam|wc -l)
counter=0

#Seeing if there are more than one file, for grammar reasons later on
if [ "$fileTotal" -gt "1" ]; then
plural="s"
else
plural=""
fi

#Assuming you are in the project directory, makes a new directory for output files. Will overwrite any existing "/bigWigs" directories!!
mkdir -p ../bigWigs
cd ../bigWigs


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
echo "----------------------------------------------------"

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
echo "----------------------------------------------------"
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
echo "----------------------------------------------------"

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
echo "----------------------------------------------------"
echo

done

echo "All done making bigWigs!"
fi
}

pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

## A function to check to make sure there are no directories that will be overwritten
check_files() {
badDir=false
if test -d ../Concatenated_FASTQ_files
	then
	echo "Careful, looks like directory ./Concatenated_FASTQ_files already exists"
	badDir=true
	fi
if test -d ./trimmed_reads
	then
	echo "Careful, looks like directory ./trimmed_reads already exists"
	badDir=true
	fi 
if test -d ../aligned_reads
	then
	echo "Careful, looks like directory ./aligned_reads already exists"
	badDir=true
	fi
if test -d ../bigWigs
	then
	echo "Careful, looks like directory ./bigWigs already exists"
	badDir=true
	fi 
if $badDir
	then
	read -p "${bold}It looks like you have some problems with existing directories.
${red}Would you like to quit? [Y/N] ${normal}" yn
	echo
		case $yn in
       	 	[Yy]* ) echo "${red}Exiting...${normal}"; exit;;
        	[Nn]* ) echo "Remember that existing directories with be overwritten";;
        	* ) echo "Please answer 'Y' or 'N'.";;
    		esac
	fi
}

# function to display menus
show_menus() {
	echo "${red}${bold}~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~${normal}"
	echo ""
	echo "${bold}1.${normal} Concatinate FASTQ files"
	echo "${bold}2.${normal} Trim FASTQ files"
	echo "${bold}3.${normal} Map FASTQ files"
	echo "${bold}4.${normal} Filter SAM files"
	echo "${bold}5.${normal} Make bedgraphs and bigWigs"
	echo
	echo ${bold}"0.${normal} Quit"
	echo ""
}

#Get user in put and invoke choices
read_options(){
	local startChoice
	local endChoice
	local badInput=true

	while $badInput
	do
	read -p "At what step would you like to begin?  " startChoice
	if test $startChoice -eq 0
		then
		exit
	fi 
	read -p "At what step would you like to end?  " endChoice
	local bad=true
	if test $endChoice -eq 0
		then
		exit
	fi 
	if test $startChoice -lt 1 -o $startChoice -gt 5 -o $startChoice -gt $endChoice
		then
		echo "Check your starting choice, I don't recognize a menu option"
		bad=false
	fi
	if test $endChoice -lt 1 -o $endChoice -gt 5 -o $endChoice -lt $startChoice
		then
		echo "Check your ending choice, I don't recognize a menu option"
		bad=false
	fi
	if  $bad 
		then
		badInput=false
		fi
	echo $badInput
	done

	local counter="$(($endChoice-$startChoice+1))"
	until [ $counter -lt 1 ]
	do
		if test $startChoice -eq 1
		then
			cat_reads
		fi
		if test $startChoice -eq 2
		then
			trimmomatic_reads
		fi
		if test $startChoice -eq 3
		then
			if rna = "RNA"
			then
			hisat2_align rna
			else
			bowtie2_align
			fi
		fi
		if test $startChoice -eq 4
		then
			sam_filter
		fi
		if test $startChoice -eq 5
		then
			make_bigWigs
		fi
		if test ! $startChoice -eq $endChoice
		then
		startChoice="$((startChoice+1))"
		fi

		counter="$(($counter-1))"
		sleep 1
	done
	

}
 
## Step #3: Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP
 
## Main loop
clear
echo "${bold}Starting up..."
echo
echo "${bold}Your current directory is :${normal}${green}"
pwd
echo "${normal}${bold}Make sure this is where the raw read files (.fastq.gz) are located${normal}"
echo
echo
sleep 2

check_files
rna=""
read -p "Are the data from an RNA-seq experiment? [Y/N] " yn
	echo
	case $yn in
       	[Yy]* ) echo "Settings are now set for ${green}'RNA'${normal} data"; rna="RNA";;
        [Nn]* ) echo "Settings are now set for ${green}'Genomic'${normal} data";;
        * ) echo "Please answer 'Y' or 'N'.";;
    	esac
echo

while true
do
	show_menus
	read_options
	read -p "${bold}${green}Everything is finished! Would you like to quit? [Y/N] ${normal}" yn
		echo
		case $yn in
       		[Yy]* ) echo "Quitting... "; exit;;
        	[Nn]* ) echo "Starting over from menu!";;
        	* ) echo "Please answer 'Y' or 'N'.";;
    	esac
done
