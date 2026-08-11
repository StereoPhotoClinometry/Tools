#!/bin/bash

# This script is used to look at how TRIMMER is 
# modifying the shape. TRIMMER operates on SHAPEX.TXT.
#
# The script creates the 10 shapeviews. It copies 
# the images into the SHAPEVIEWS directory and opens 
# each image. The file names have the first argument 
# appended to them so that you can run this script for
# multiple trim steps and know which images go with 
# which trim step.
#
# It also makes an imager_grid so that you can
# compare the image to the trimmed shape.
#
# Comments added by Terik Daly 1/4/21
# imager_grid feature added by Terik Daly 4/23/21
# ICQ2PLT and PLT2OBJ added by Terik Daly 5/26/21

# Make view_shape look at SHAPEX.

#echo -e 'SHAPEFILES/SHAPEX.TXT' | shape2maps

# Run view_shape
#echo "~~~~Running view_01~~~~"
#cp geometry_01.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_01_trim${1}.pgm

#echo "~~~~Running view_02~~~~"
#cp geometry_02.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_02_trim${1}.pgm

#echo "~~~~Running view_03~~~~"
#cp geometry_03.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_03_trim${1}.pgm

#echo "~~~~Running view_04~~~~"
#cp geometry_04.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_04_trim${1}.pgm

#echo "~~~~Running view_05~~~~"
#cp geometry_05.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_05_trim${1}.pgm

#echo "~~~~Running view_06~~~~"
#cp geometry_06.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_06_trim${1}.pgm

#echo "~~~~Running view_07~~~~"
#cp geometry_07.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_07_trim${1}.pgm

#echo "~~~~Running view_08~~~~"
#cp geometry_08.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_08_trim${1}.pgm

#echo "~~~~Running view_09~~~~"
#cp geometry_09.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_09_trim${1}.pgm

#echo "~~~~Running view_10~~~~"
#cp geometry_10.in geometry.in
#view_shape
#mv view.pgm SHAPEVIEWS/view_10_trim${1}.pgm

# run display and imager_grid with an alternate shape
# so we can see what the image looks like
# vs. the newly trimmed shape.

echo -e "${2}\n0\nn\nn" | Display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${2}_R.png

echo -e "${2}\ny\nSHAPEFILES/SHAPEX.TXT\nn" | /usr/local/bin/spc/satanic/bin/imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${2}_G_${1}.png

# make an obj file so you can look at it in Paraview
ICQ2PLT SHAPEFILES/SHAPEX.TXT SHAPEFILES/SHAPEX.PLT
PLT2OBJ SHAPEFILES/SHAPEX.PLT SHAPEFILES/SHAPEX_${1}.obj

# open the files
open ./Display/${2}_R.png
open ./Display/${2}_G_${1}.png
#open SHAPEVIEWS/view_01_trim${1}.pgm
#open SHAPEVIEWS/view_02_trim${1}.pgm
#open SHAPEVIEWS/view_03_trim${1}.pgm
#open SHAPEVIEWS/view_04_trim${1}.pgm
#open SHAPEVIEWS/view_05_trim${1}.pgm
#open SHAPEVIEWS/view_06_trim${1}.pgm
#open SHAPEVIEWS/view_07_trim${1}.pgm
#open SHAPEVIEWS/view_08_trim${1}.pgm
#open SHAPEVIEWS/view_09_trim${1}.pgm
#open SHAPEVIEWS/view_10_trim${1}.pgm
