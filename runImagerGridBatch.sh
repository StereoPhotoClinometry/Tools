#!/bin/bash

# This script uses a while read loop to run a batch of images
# through imager_grid. It converts the .pgm file written by
# imager_grid into a png. It copies the fake images into the Display
# directory with _imagerGrid in the filename to differentiate the fake
# images from the real images. It reads from a list of images in
# a file given as an argument to the script.

# Comments added 12/29/20 by Terik Daly.

while read line
do
echo -e "${line}\nn" | Imager_Grid
magick TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_imagerGrid.png
done <$1

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT
