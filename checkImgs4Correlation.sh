#!/bin/bash

# Terik Daly, 2 February 2021

# This reads the images in PICTLIST.TXT and checks the OOT files
# to see if that image is flagged in any of the OOT files because
# of image correlation issues. It makes a file that contains
# the name of each image, followed by the # of LMKs in which it is
# flagged.
done
while read line
do
echo $line
grep "check:  ${line}" *OOT | wc -l
done <PICTLIST.TXT >NumTimesImageFlaggedinOOT.txt

# To make the file eaiser to work with, the remaining commands
# rearrange things so that the image name is in one column
# and the number of times the image is flagged is in the next
# column. That makes it easier to sort/triage the images.
sed -n 'n;p'  NumTimesImageFlaggedinOOT.txt >number.tmp
sed -n 'p;n'  NumTimesImageFlaggedinOOT.txt >image.tmp
paste image.tmp number.tmp >NumTimesImageFlaggedinOOT.txt
rm image.tmp
rm number.tmp
