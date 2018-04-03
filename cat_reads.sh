#! /bin/sh
#concatenate replicates from different lanes and looping over all files in the current directory
list=""
for file in ./*.fastq.gz
#extract the basename of the file by taking everything up to the reads-either single end or paired end

do
tmp=${file##*/}
basename=${tmp%%"_R?_"}
list+="${basename}"
done

#looping through list of basenames and comparing to every other sample and finding the same sample in a different lane
for sample in list
do
  for basename in sample
  do
    if basename == basename; then
      zcat ${basename} ${basename} | gzip > /home/harrison/Desktop/Documents/CRY2-ZLD/Concatenated_FASTQ_file/${basename}_cat.fastq.gz
    fi
  done
done

done
