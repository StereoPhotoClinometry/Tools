#!/bin/bash

# This script uses a while read loop to run a batch of images
# through imager_mg. It magicks the .pgm file written by
# imager_grid into a png. It copies the fake images into the Display
# directory with _imagerGrid in the filename to differentiate the fake
# images from the real images. It reads from a list of images in
# a file given as an argument to the script.

# NOTE: THIS ASSUMES SATANIC IMAGER_MG!!
# THIS ALSO ASSUMES THAT YOU HAVE THE LMKs YOU WANT TO LOOK AT LISTED IN MAPLIST.TXT

# 12/15/25 by Terik Daly

while read line
do
echo -e "n\n${line}\nn" | imager_MG
magick TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_imagerMG.png
done <$1

rm ./*.DAT
