#! /bin/sh

for file in CRY_10_1_S3   CRY_NL_3_S17 CRY_10_2_S4   CRY_NL_4_S18 CRY_10_4_S12  WT_10_1_S1 CRY_13_1_S7   WT_10_2_S2 CRY_13_2_S8   WT_10_4_S11 CRY_13_3_S15 WT_13_1_S5 CRY_13_4_S16  WT_13_2_S6 CRY_NL_1_S9  WT_13_3_S13 CRY_NL_2_S10  WT_13_4_S14

#for file in CRY_10_1_S3

do

echo ${file}
ls ${file}_al.sam
date

echo "input reads:"
samtools view ${file}_al.sam | wc -l

samtools view -h  ${file}_al.sam | grep -e ^@ -e NH:i:1 | samtools view -bh -o ${file}_filtered.bam -

echo "output reads:"
samtools view ${file}_filtered.bam | wc -l


date
echo "\n"
done
