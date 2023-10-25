#!/bin/bash

# Terik Daly
# 15 February 2021

# This looks at the LMKFILE for each LMK in LMRKLIST
# to see if an image is asterisked out or not. It makes a 
# file that contains the name of each LMK, followed by the
# number of images in that LMK that are asterisked out.

while read line
do
echo ${line}
grep "\*" LMKFILES/${line}.LMK | wc -l
done <LMRKLIST.TXT >NumAsteriskedImgsPerLMK.txt


# To make the file eaiser to work with, the remaining commands
# rearrange things so that the image name is in one column
# and the number of times the image is flagged is in the next
# column. That makes it easier to sort/triage the images.

sed -n 'n;p'  NumAsteriskedImgsPerLMK.txt >numberStar.tmp
sed -n 'p;n'  NumAsteriskedImgsPerLMK.txt >imageStar.tmp
paste imageStar.tmp numberStar.tmp >NumAsteriskedImgsPerLMK.txt
rm imageStar.tmp
rm numberStar.tmp
