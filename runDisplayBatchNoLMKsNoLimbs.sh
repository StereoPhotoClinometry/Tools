#!/bin/bash

# This script uses a while read loop to run a batch of images
# through Display. It converts the .pgm file written by
# Display into a png. It saves the real images into the Display
# directory with _Rc in the filename to distinguish real, "clean"
# from fake images. This script does not show a single landmark and
# does not show limbs. It also does not change any thresholds.
# It simply makes the images. 

# Created 12 January 2021 by Terik Daly (terik.daly@jhuapl.edu)

while read line
do
echo -e "$line\ny\n0\nn\nn\nn" | Display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_Rclean.png
done <list-of-pics-to-check.txt

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT

