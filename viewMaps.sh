#!/bin/bash
# Simple script to run all 10 geometry options
# 	Eric E. Palmer - 7 Aug 2014

# c ...................................
#cp -f LMRKLIST.TXT view_maps.in

if [ -d "SHAPEVIEWS" ]
then
    echo "Directory SHAPEVIEWS exists."
else
    echo "Error: Directory SHAPEVIEWS does not exists - creating it now."
    mkdir SHAPEVIEWS
fi

dt="`date +"%Y-%m-%d_%H-%M-%S"`"
arg=5

if [ $# -eq 0 ]
then
read -p "Enter view_maps command (0-6; default=5): " arg
else
arg=$1
fi


list="01 02 03 04 05 06 07 08 09 10"

for i in $list
do
	echo "~~~~Running view_$i~~~~"
	if [ -f "support/geometry_$i.in" ]; then
  		cp -f support/geometry_$i.in geometry.in
	else
  		cp -f geometry_$i.in geometry.in
	fi
	
	echo $arg | view_maps
	convert view.pgm SHAPEVIEWS/view_${i}_maps_$dt.jpg
	open SHAPEVIEWS/view_${i}_maps_$dt.jpg
done

exit


