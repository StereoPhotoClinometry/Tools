#!/bin/bash

# This script uses a while read loop to run a single 
# through a bunch of different shapes imager_grid. 
# The user to specify which image to use as an argument. The shapes
# are given in a text file. It converts the .pgm file written by
# imager_grid into a png. It copies the fake images into the Display
# directory with _G_shape in the filename to differentiate the fake
# images from the real images. 

# The first argument, $1, is the name of the image you want to use.
# The second argument, $2, is list of shape models WITHOUT SHAPEFILES.
# SHAPEFILES is hardcoded.

# 11/18/21 by Terik Daly.

while read line
do
echo -e "${1}\ny\nSHAPEFILES/${line}\nn" | imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${1}_G_${line}.png
done <${2}

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT
