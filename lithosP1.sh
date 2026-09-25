#!/bin/bash

# A script to run a batch of images through the p1 (tuck) option in lithos.
# This tucks (or untucks) images.
#
# To use the script, you need to give as an argument the name of a list
# of images that you wish to p1 (i.e., of images to tuck).
# The script will read that list and
# then write a file, p1Me.txt, that contains the commands needed
# to p1 all of those images. The last part of the script feeds
# those commands into lithos, thereby running the images through the p1
# option.
#
# Use example: lithosp1.sh toTuck.txt
#
#
# Terik Daly, 5 May 2021
#
while read line
do
echo p
echo $line
echo 1
done < ${1} > p1Me.txt | lithosx1 < p1Me.txt