#!/bin/bash
# Simple script to run all 10 geometry options
# 	Eric E. Palmer - 7 Aug 2014


list="01 02 03 04 05 06 07 08 09 10"

for i in $list
do
	echo $i
	cp -f support/geometry_$i.in geometry.in
	view_shape
	convert view.pgm view_$i.jpg
done



convert -adjoin -loop 0 -delay 40 view_0[1-8].jpg shape.gif
