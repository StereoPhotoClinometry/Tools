#!/bin/bash

# This script uses a while read loop to run a batch of images
# through DisplayX. It converts the .pgm file written by
# Display into a png. It saves the real images into the Display
# directory with _R in the filename to distinguish real
# from fake images. This script does not show a single landmark and
# does not show limbs. It also does not change any thresholds.
# It simply makes the images. You provide the image list as an argument.

# Comments added 12/29/20 by Terik Daly.

while read line
do
echo -e "${line}\n0\nn\nn" | DisplayX
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_R.png
done <${1}

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT
