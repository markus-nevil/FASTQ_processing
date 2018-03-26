#! /bin/sh

## loop over all the files in the current directory ending in "_filtered.bam"
for file in ./*_filtered.bam

do
## extract the basename of the file by taking everything up to "_filtered.bam"
tmp=${file##*/}
basename=${tmp%%"_filtered.bam"}

date
echo "starting ${basename}"
ls ${file}

featureCounts [options] -a <annotation_file> -o <output_file> ${file}

echo "${basename} done"
date
echo "\n"

done
