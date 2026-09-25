#!/bin/bash

# A script to run a batch of images through the v3 option in lithosx1.
# This is an alternative to running geometryX on those images, which 
# has led to NaNs in the past.
#
# To use the script, you need to give as an argument the name of a list
# of images that you with to v3. The script will read that list and
# then write a file, v3Me.txt, that contains the commands needed
# to v3 all of those images. The last part of the script feeds
# those lines into lithosx1, thereby running the images through the v3
# option.
#
# Use example: lithosV3.sh linescans.txt
#
#
# Terik Daly, 4 May 2021
#
while read line
do 
echo v
echo 3
echo $line
echo n
echo n
done < ${1} > v3Me.txt | lithosx1 < v3Me.txt
