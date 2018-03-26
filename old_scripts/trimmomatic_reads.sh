#! /bin/sh

for file in CRY_10_1_S3   CRY_NL_3_S17 CRY_10_2_S4   CRY_NL_4_S18 CRY_10_4_S12  WT_10_1_S1 CRY_13_1_S7   WT_10_2_S2 CRY_13_2_S8   WT_10_4_S11 CRY_13_3_S15 WT_13_1_S5 CRY_13_4_S16  WT_13_2_S6 CRY_NL_1_S9  WT_13_3_S13 CRY_NL_2_S10  WT_13_4_S14

do

echo ${file}

#zcat ${file}_L003_R1_001.fastq.gz ${file}_L004_R1_001.fastq.gz | gzip > /home/harrison/Desktop/Documents/CRY2-ZLD/Concatenated_FASTQ_file/${file}.fastq.gz

java -jar /home/harrison/Desktop/Trimmomatic-0.36/trimmomatic-0.36.jar SE -trimlog ${file}_trimlog.txt ${file}.fastq.gz ${file}_trim.fastq.gz ILLUMINACLIP:/home/harrison/Desktop/Trimmomatic-0.36/adapters/TruSeq2-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:22 MINLEN:70


done
