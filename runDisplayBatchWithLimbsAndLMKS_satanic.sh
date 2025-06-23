#!/bin/bash

# This script runs Display on a set of images in the file given as
# as an argument to the script. It shows limb points. It
# converts the .pgm to a png and puts that png in the Display folder.

# Comments added by Terik Daly 12/28/20

while read line
do
echo -e "$line\n0\nn\ny\nn" | Display
#echo -e "$line\nn\ny\nn" | Display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_withLimbs.png
done <$1

rm ./*.DAT

rm SHAPEFILES/*PLT
rm *DAT
