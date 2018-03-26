#! /bin/sh

for file in CRY_10_1_S3   CRY_NL_3_S17 CRY_10_2_S4   CRY_NL_4_S18 CRY_10_4_S12  WT_10_1_S1 CRY_13_1_S7   WT_10_2_S2 CRY_13_2_S8   WT_10_4_S11 CRY_13_3_S15 WT_13_1_S5 CRY_13_4_S16  WT_13_2_S6 CRY_NL_1_S9  WT_13_3_S13 CRY_NL_2_S10  WT_13_4_S14

do

echo ${file}
date

hisat2 -k 2 -x /home/harrison/Desktop/Documents/CRY2-ZLD/Genome_indexes/dm6/dm6 -U /home/harrison/Desktop/Documents/CRY2-ZLD/Concatenated_FASTQ_file/${file}_trim.fastq.gz -S ${file}_al.sam --un ${file}_un.sam --summary-file ${file}_summary.txt

date
echo "\n"
done
