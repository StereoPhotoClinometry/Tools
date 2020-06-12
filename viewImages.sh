#!/bin/bash
# Simple script to make thumbnails of a list of images
# It puts them into the "send" directory in your home directory
# 	Eric E. Palmer - 7 Aug 2014

list=`cat $1`
mkdir -p ~/send

for i in $list
do
	bad=`echo $i | grep \!` 

	if [ -n $bad ]
	then
		echo $i
		echo "$i" > tmp
		echo "0" >> tmp
#		echo "y" >> tmp
#		echo "0" >> tmp
		echo "n" >> tmp
		echo "n" >> tmp
		echo "n" >> tmp
		/usr/local/bin/Display < tmp
		convert TEMPFILE.pgm ~/send/$i.jpg
	else
		echo skipping $i
	fi
done

exit

