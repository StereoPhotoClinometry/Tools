#!/bin/bash
# Simple script to run all 10 geometry options
# 	Eric E. Palmer - 7 Aug 2014

c ...................................
#cp -f LMRKLIST.TXT view_maps.in

list="01 02 03 04 05 06 07 08 09 10"

for i in $list
do
	echo $i
	cp -f support/geometry_$i.in geometry.in
	echo 5 | view_maps
	convert view.pgm view_$i.jpg
done

exit


