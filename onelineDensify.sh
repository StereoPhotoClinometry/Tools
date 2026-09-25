#!/bin/bash

# This script runs densify for an ICQ shape model supplied 
# in an input file. The required arguments are:
# The input file (assuming for now it's in the SHAPEFILES directory), no ".TXT"
# a 2 or -2
# The search distance you want to use
# An output filename (no .TXT; program assumes you want it in SHAPEFILES/)
# Whether you want to run "densify" or "densifya".

# If we want to make this smarter in the future, can make a $5 directory name 
# but have it default to "SHAPEFILES" if not supplied...

# Carolyn Ernst 11/29/2021

# example:
# ./onelineDensify.sh shapename.TXT -2 0.008 SHAPE0_testing densifya

directory=SHAPEFILES
two=$2
scale=$3
appendage=$4
densify_type=$5

if [ $5 == "densify" ]
then
    echo "Running densify."
  
elif [ $5 == "densifya" ]
then
    echo "Running densifya."
else 
	echo "Please choose either densify or densifya."
	exit 1
fi


if [ -d ${directory} ]
then
    echo "Directory ${directory} exists."
else
    echo "Error: Directory ${directory} does not exists - creating it now."
    mkdir ${directory}
fi


# make the densify input file
echo "${directory}/${1}.TXT" >${directory}/densify.tmp
echo "${two} ${scale} 2839" >>${directory}/densify.tmp
echo "${directory}/SHAPEX.TXT" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "0.005" >>${directory}/densify.tmp
echo "0.025" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "1" >>${directory}/densify.tmp
echo "0" >>${directory}/densify.tmp

${densify_type} <${directory}/densify.tmp

# ICQ2PLT "${directory}/SHAPEX.TXT" "${directory}/SHAPEX.PLT"
# PLT2OBJ "${directory}/SHAPEX.PLT" "${directory}/${appendage}.obj"

cp "${directory}/SHAPEX.TXT" "${directory}/${appendage}.TXT"

cp "${directory}/${appendage}.TXT" "${directory}/${appendage}.icq"
PointCloudFormatConverter -inputFile "${directory}/${appendage}.icq" -outputFile "${directory}/${appendage}.obj"

if [ $5 == "densifya" ]
then
 cp "${directory}/SIGMA.TXT" "${directory}/SIGMA_${appendage}.TXT"
fi


#rm ${directory}/SHAPEX.PLT



echo ""
echo "********** Built ${directory}/${appendage}.TXT **********"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "(\ /)"
echo "( . .) Thanks for using onelineDensify. Have a great day, and SPC responsibly."
echo "c(#)(#)"
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""


rm SHAPEFILES/*PLT
rm *DAT

