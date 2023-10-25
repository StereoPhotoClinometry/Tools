#!/bin/bash

# This script uses a while read loop to run a batch of images
# through imager_grid. It allows the user to specify which shape
# model to use. It converts the .pgm file written by
# imager_grid into a png. It copies the fake images into the Display
# directory with _G in the filename to differentiate the fake
# images from the real images. 

# The first argument, $1, is the name of image list, including relative path.
# The second argument, $2, is the name of the alernative shape model, including relative path.

# Comments added 12/29/20 by Terik Daly.

while read line
do
echo -e "$line\ny\n$2\nn" | imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_G_alt.png
done <$1

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT
