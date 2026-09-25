#!/bin/bash

# This script uses a while read loop to run a batch of images
# through display, imager_grid, and imager_mg.
# It converts the .pgm file written by each of these into a .png.
# It copies the fake images into the Display
# directory with filenames to differentiate the different images.
# It reads from a list of images in
# a file given as an argument to the script.

# Example usage:
# support/runLimbComparisons.sh limbMaplets.txt pics4limbs.txt 4

# where limbMaplets is what you want to use for MAPLIST, pics5limbs has
# the images you want to look at and 4 gets appendded to the filename so
# that if you iterate the maplets mulitple times you don't overwrite the 
# files. That way you can see how things are changing.

# 12/30/21 by Terik Daly.

# Get MAPLIST in place. This is an argument so you can choose betwee
# all LMKs or some subset of them.

rm MAPLIST.TXT
support/relink.sh ${1} MAPLIST.TXT
ls -l MAPLIST.TXT | tee -a notes

# Display
while read line
do
echo -e "${line}\n0\nn\nn" | Display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_image_${3}.png
done <${2}

# Imager_grid
while read line
do
echo -e "${line}\nn" | Imager_Grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_imagerGrid_${3}.png
done <${2}

# Imager_MG
while read line
do
echo -e "${line}\nn" | Imager_mg
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_imagerMG_${3}.png
done <${2}

# open what you made
open ./Display/*_image_${3}.png
open ./Display/*_imagerGrid_${3}.png
open ./Display/*_imagerMG_${3}.png

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT



