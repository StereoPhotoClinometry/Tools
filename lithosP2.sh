#!/bin/bash

# A script to run a batch of images through the p2 option in lithos.
# This un-Ts (or Ts) SUMFILES of images so that they do not (or do)
# participate in geometry.
#
# To use the script, you need to give as an argument the name of a list
# of images that you wish to p2 (i.e., of SUMFILES to un-T).
# The script will read that list and
# then write a file, p2Me.txt, that contains the commands needed
# to p2 all of those images. The last part of the script feeds
# those commands into lithos, thereby running the images through the p2
# option.
#
# Use example: lithosp2.sh linescans.txt
#
#
# Terik Daly, 5 May 2021
#
while read line
do
echo p
echo $line
echo 2
done < ${1} > p2Me.txt | lithos < p2Me.txt
