#! /bin/bash
#loop over all files in the current directory ending in "_cat.fastq.gz"

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

trimmomatic_reads
