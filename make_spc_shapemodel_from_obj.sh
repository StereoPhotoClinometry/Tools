#!/bin/bash

# This script is used to translate a shape model from SBMT format to Bob’s
#
# This script assumes ALTWG is set up, but that SBCLT commands are defaults. *NOTE* May need to adjust paths
#
# Comments added by Ally Glantzberg 1/22/2025


# Path to altwg library
export DYLD_LIBRARY_PATH=~/Downloads/altwg-2020.03.18-macosx-x64/lib

# path to altwg AdjustShapeModelToOtherShapeModel
AdjustShapeModelToOtherShapeModel=~/Downloads/altwg-2020.03.18-macosx-x64/bin/AdjustShapeModelToOtherShapeModel

# path to altwg ll2shape
ll2shape=~/Downloads/altwg-2020.03.18-macosx-x64/bin/ll2shape

# Use the lon/lat/radius txt file to fit a low res spherical harmonic solution to the shape model
echo "text input exists? (y/n)"
read textInput

if [ "$textInput" == "y" ]
then
echo "input text file"
read ll2shapeInput
icqShape=`sed -n 2p $ll2shapeInput`
$ll2shape<$ll2shapeInput &

else
echo "input shape (.txt file)"
read inputShape
echo "output icq shape basename "
read icqOutShape
echo "format (1. lat/elon/rad, 2. lat/wlon/rad, 3. elon/lat/rad, 4. wlon/lat/rad)"
read format
echo "input q (64, 128, 256, 512)"
read q
echo "input l (standard l=15)"
read l

# icqShape= "${icqOutShape%.icq}"_"q$q"_"l$l.icq"
icqShape=`echo "$icqOutShape"_"q$q"_"l$l.icq"`

echo "$inputShape">tmpll2shape.txt
echo "$icqShape">>tmpll2shape.txt
echo "$format">>tmpll2shape.txt
echo "$q, $l">>tmpll2shape.txt

$ll2shape<tmpll2shape.txt &

fi

wait
echo "$icqShape"


# convert icq to obj

echo "Convert Shape to OBJ: "

echo "Input convert text file? (y/n)"
read convertTxt

if [ "$convertTxt" == "y" ]
then
echo "input converter text file"
read convertInput
objOut=`sed -n 1p $convertInput `
xs=`sed -n 1p $convertInput`
ys=`sed -n 2p $convertInput`
zs=`sed -n 3p $convertInput`
fpr=`sed -n 4p $convertInput`
sbmtObj=`sed -n 5p $convertInput`
spcObj=`sed -n 6p $convertInput`

else
echo "input x y z scale"
read -r xs ys zs
echo "input fit plane radius"
read fpr
echo "input sbmt obj"
read sbmtObj
echo "input spc shape filename (as .obj)"
read spcObj

fi


ShapeFormatConverter -scale $xs,$ys,$zs -input $icqShape -inputFormat ICQ -output ${icqShape%.icq}.obj -outputFormat OBJ

echo "Adjust Shape Model:"
echo $fpr

$AdjustShapeModelToOtherShapeModel --fit-plane-radius $fpr ${icqShape%.icq}.obj $sbmtObj $spcObj



