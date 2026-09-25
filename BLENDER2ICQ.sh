#!/bin/bash

# This script converts an obj file exported by blender into an obj file that
# can be used in OBJ2ICQ. It also outputs a .txt file that is in the ICQ format
# for SPC.
# The required arguments are:
# The input file name, no “.obj”.i
# The Q size of the final ICQ/OBJ.
# The spherical harmnoic degree for the ll2shape run.
# This program assumes you want your input and output base names to be the same.

# Carolyn Ernst 09/22/2022

# example:
# ./BLENDER2ICQ.sh shapename 128 15

echo "${1}"

PointCloudFormatConverter -inputFile "${1}.obj" -inputFormat OBJ -outllr -outputFile llr.txt -outputFormat ASCII

echo -e "llr.txt\nllr.icq\n1\n${2} ${3}" | ll2shape

#ICQ2PLT llr.icq llr.plt
#PLT2OBJ llr.plt llr.obj

ShapeFormatConverter -input llr.icq -output ll2.obj

AdjustShapeModelToOtherShapeModel llr.obj ${1}.obj ${1}_ll.obj

#OBJ2ICQ ${1}_ll.obj ${1}_ll.TXT

ShapeFormatConverter -input ${1}_ll.obj -output ${1}_ll.TXT

rm llr.txt
rm llr.icq
# rm llr.plt

echo ""
echo "********** Wrote ${1}_ll.obj **********"
echo ""
echo ""

