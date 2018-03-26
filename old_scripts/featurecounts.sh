#! /bin/sh

## insert path to GTF formatted annotation file
#GTF=/home/harrison/Desktop/Documents/CRY2-ZLD/dm6.refGene.GTF
GTF=/home/harrison/Desktop/Documents/CRY2-ZLD/dmel-all-r6.20.ucsc.gtf

## select the set of input files as all files in the current directory ending in _filtered.bam
infiles=./*_filtered.bam


## run featureCounts, sending ouput count table to the file "count_table.txt"
## unless told otherwise, featureCounts will count the reads aligning to exons in the annotation file. To specify another feature to count, use the -t option

featureCounts -a ${GTF} -o count_table.txt ${infiles}



