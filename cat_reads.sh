#! /bin/bash
#concatenate replicates from different lanes and looping over all files in the current directory

cat_reads() {

list=()
for file in ./*.fastq.gz
#extract the basename of the file by taking everything up to the reads-either single end or paired end

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


#cat_reads "RNA"

