#!/bin/bash

# This script is used to look at how TRIMMER is 
# modifying the shape. TRIMMER operates on SHAPEX.TXT.
#
# It runs imager_grid so that you can compare the 
# trimmed shape to image(s) of your choosing. The name
# of the imagelist is the second argument in the script.
#
# Comments added by Terik Daly 1/4/21
# imager_grid feature added by Terik Daly 4/23/21
# Updated to read from a list of images, rather than a single image name
#   by Terik Daly 1-12-22

# Run imager_grid so you can compare the image
# to the trimmed shape.

# the current shape
echo -e "${2}\nn" | imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./SHAPEVIEWS/${2}_shape.png

# the trimmed shape
echo -e "${2}\ny\nSHAPEFILES/SHAPEX.TXT\nn" | imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./SHAPEVIEWS/${2}_trim${1}.png

# the real image
echo -e "${2}\nn\nn\n" | display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./SHAPEVIEWS/${2}_image.png

# open the files
open ./SHAPEVIEWS/${2}_trim${1}.png
open ./SHAPEVIEWS/${2}_shape.png
open ./SHAPEVIEWS/${2}_image.png
