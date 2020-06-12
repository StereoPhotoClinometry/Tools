#!/bin/bash
# Eric E. Palmer, 21 March 2019
# Gets important info for each image (lat/lon/# landmarks)


file=$1

if [ "$file" == "" ]
then
	echo "#####################"
	echo "No file listed"
	eho "Usage $0 <file>"
fi

blank=`head -1 $file | cut -c 1`

if [ "$blank" == " " ]
then
	echo "Bob's image format"
else
	echo "Normal list format"
fi

list=`cat $1`
 
d=`date`
echo "#$d" > results
echo "#Image          lat      lon      res    map        limb     code   residual    disp" >> results

for item in $list
do

	if [ "$item" == "END" ]
	then
		break;
	fi
	first=`echo $item | cut -c 1`
	if [ "$first" == "!" ]
	then
		continue;
	fi
	echo $item
	echo "f" > tmpRun
	echo "p" >> tmpRun
	echo "$item" >> tmpRun
	echo "512, 512" >> tmpRun
	echo "q" >> tmpRun
	LITHOS < tmpRun > tmpOut.txt
	lat=`grep Lat tmpOut.txt | cut -c 18-36`
	if [ "$lat" == "" ]
	then
		lat="########    ######## "
	fi
	echo -n "$item $lat "  >> results
	grep $item PICINFO.TXT| cut -c 45-51,60-105 >> results

done

