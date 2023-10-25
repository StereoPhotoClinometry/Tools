#!/bin/bash

# This script uses a while read loop to run a batch of images
# through limber. It copies the LIMBVECS.TXT file written by
# limber into a text file with the name of the image as the filename.
# WARNING - this will overwrite any existing LIMBER.TXT and LIMBVECS.TXT file!!

# Created 25 October 2021 by Carolyn Ernst

#bulk_limber_files inputlist.txt


#echo "Running this program will overwrite LIMBVECS.TXT and LIMBER.TXT. Are you sure you want to proceed? (y/n)" answer
#if [ $answer == "n" ]
#then
#    echo "Cancelling script!"
#else 



if [ -d LIMBSBMT ]
then
    echo "Directory LIMBSBMT exists."
else
    echo "Error: Directory LIMBSBMT does not exists - creating it now."
    mkdir LIMBSBMT
fi


while read line
do
echo ${line}
# make LIMBER.TXT input file
echo " ${line}" > LIMBER.TXT
echo "END" >> LIMBER.TXT

#limber
~/SPC_repositories/SPOC-2020-02-13/BIN/LIMBERdec2020

awk '{ print $1, $2, $3 }' LIMBVECS.TXT | tail -n+2 > ${line}.limb
perl -p -i -e "s/END//g" ${line}.limb
perl -p -i -e "s/D/E/g" ${line}.limb

mv "${line}.limb" "LIMBSBMT/"


done < "$1"

rm "LIMBSBMT/END.limb"

#fi

rm SHAPEFILES/*PLT
rm *DAT

