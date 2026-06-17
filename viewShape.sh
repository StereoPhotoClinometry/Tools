#!/bin/bash
# Simple script to run all 10 geometry options
# 	Eric E. Palmer - 7 Aug 2014


list="01 02 03 04 05 06 07 08 09 10"

for i in $list
do
	echo "~~~~Running ${i} ~~~~"
	if [ -f "support/geometry_$i.in" ]; then
  		cp -f support/geometry_$i.in geometry.in
	else
  		cp -f geometry_$i.in geometry.in
	fi
	view_shape
	magick view.pgm view_$i.jpg
	open view_$i.jpg
done


magick -adjoin -loop 0 -delay 40 view_0[1-8].jpg shape.gif
open shape.gif
