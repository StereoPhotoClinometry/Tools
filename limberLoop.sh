#!/bin/bash

# This script runs limber in a loop
# To run: ./limberLoop.sh <pic list filename> <limber input file> <qsize> <lmin> <lmax> <lChoice> <number of loops>
# Where:
# pic list filename = the file with the list of pictures to pass through limber (ex. PICTLIST.TXT)
# limber input file = the .in file tthat contains the set of limber commands to execute (ex. limber.in)
# qsize = the q value that the output shape model should have (ex. 128)
# lmin/lmax = the min/max sphereical harmonics order (ex. 3/17)
# lChoice = the starting point harmonic to use for the next round of each loop through limber betweeen lmin and lmax
# number of loops = the number of times to execute limber (ex. 7)
#
# Thus, an example execution command might look like: `./limberLoop.sh PICLIST.TXT limber.in 128 3 17 9 7`
# 
#
# Edited by Ally Glantzberg (allison.glantzberg@jhuapl.edu) 2025-07-17

echo "Required No. of Args: 7"
echo "No. of Args provided: $#"

if [[ $# -ne 7 ]]; then
read -p "Enter the filename with the list of pictures you want to limber (ex. PICTLIST.TXT): " limberFile
read -p "Enter limber input filename (ex. limber.in): " limberIn
read -p "Enter the qsize: " q
read -p "Enter lmin: " lmin
read -p "Enter lmax: " lmax
read -p "Enter the harmonic (between lmin and lmax) to use as the starting point for the next round of each loop throuogh limber: " lChoice
read -p "Enter the number of loops to execute: " nloops
else
limberFile=$1
limberIn=$2
q=$3
lmin=$4
lmax=$5
lChoice=$6
nloops=$7
fi

while [[ $lChoice -le $lmin ||  $lChoice -ge $lmax ]]
do
read -p "$lChoice is not between lmin and lmax. Please enter a number between $lmin and $lmax: " lChoice
done



cp $limberFile LIMBER.TXT
support/relink.sh support/limber.in_satanic_0.60 $limberIn
ls -l $limberIn | tee -a notes
cat $limberIn| tee -a notes


# Limber loop 1

support/limber
cd LIMBFILES
ls * >../imagesWithLimbs
cd ..
echo "Limber found limbs in the following images" >>notes 
cat imagesWithLimbs | tee -a notes
echo "end of images with limbs found by limber" >>notes
support/runDisplayBatchWithLimbs.sh imagesWithLimbs
#open ./Display/*Limbs*
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "running coverage"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
printf "0\n 0 1000\n y" | coverage
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "$"
echo "end of coverage"
cp coverage_g.pgm coverage_limbs_round1.pgm

sed '1d' SHAPEFILES/SHAPE0.TXT >VECS.TXT
sed '1d' LIMBVECS.TXT >>VECS.TXT

printf "VECS.TXT\n${q}\nSHAPEFILES/SHAPEL_q${q}_vecs2cube_round1.TXT" 
printf "VECS.TXT\n${q}\nSHAPEFILES/SHAPEL_q${q}_vecs2cube_round1.TXT" | vecs2cube

ShapeFormatConverter -input SHAPEFILES/SHAPEL_q${q}_vecs2cube_round1.TXT -output SHAPEFILES/SHAPEL_q${q}_vecs2cube_round1.obj

sed '1d' SHAPEFILES/SHAPEL_q${q}_vecs2cube_round1.TXT >newVecs.txt
support/runVecs2shapeMulti.sh newVecs.txt $q $lmin $lmax SHAPEL_q${q}_LimberLoop
echo "support/runVecs2shapeMulti.sh newVecs.txt $q $lmin $lmax SHAPEL_q${q}_LimberLoop" >> notes

cp vecs2shape/SHAPEL_q${q}_LimberLoop_vecs2shape_q${q}_l${lChoice}.TXT SHAPEFILES/SHAPEL_LimberLoop_round1.TXT
cd SHAPEFILES/
../support/relink.sh SHAPEL_LimberLoop_round1.TXT SHAPE.TXT
ls -l SHAPE.TXT | tee -a ../notes
cd ..

echo "Finished limber loop 1"


for l in {2..$nloops}
do
support/limber
printf "0\n0 1000\ny" | coverage
cp coverage_g.pgm "coverage_limbs_round$l.pgm"
sed '1d' SHAPEFILES/SHAPEL_LimberLoop_round$((l-1)).TXT >VECS.TXT
sed '1d' LIMBVECS.TXT >>VECS.TXT
printf "VECS.TXT\n${q}\nSHAPEFILES/SHAPEL_q${q}_vecs2cube_round${l}.TXT"
printf "VECS.TXT\n${q}\nSHAPEFILES/SHAPEL_q${q}_vecs2cube_round${l}.TXT" | vecs2cube
ShapeFormatConverter -input SHAPEFILES/SHAPEL_q${q}_vecs2cube_round$l.TXT -output SHAPEFILES/SHAPEL_q${q}_vecs2cube_round$l.obj
sed '1d' SHAPEFILES/SHAPEL_q${q}_vecs2cube_round${l}.TXT >newVecs.txt
support/runVecs2shapeMulti.sh newVecs.txt $q $lmin $lmax SHAPEL_q${q}_LimberLoop_round$l
echo "support/runVecs2shapeMulti.sh newVecs.txt $q $lmin $lmax SHAPEL_q${q}_LimberLoop_round${l}" >> notes
cp vecs2shape/SHAPEL_q${q}_LimberLoop_round${l}_vecs2shape_q${q}_l${lChoice}.TXT SHAPEFILES/SHAPEL_LimberLoop_round$l.TXT
cd SHAPEFILES/
../support/relink.sh SHAPEL_LimberLoop_round$l.TXT SHAPE.TXT
ls -l SHAPE.TXT | tee -a ../notes
cd ..
echo "Finished limber loop $l"
done



# compare images to shape model to see how we are doing so far
rm ~/send/*
support/evalReg.sh imagesWithLimbs

