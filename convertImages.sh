#!/bin/bash
# 	Eric E. Palmer - 7 Aug 2014
# This is to be used after makeImages.sh.
# You give it a list of image names (only the 1st 12 characters)
#		It will move them from TEMPLATES (where they were created)
#		to IMAGEFILES with a name change.
#	It will also make a thumbnail and put it in the "send" directory

#list=`cat PICTLIST.TXT`
#list=`cat short.txt`

mkdir -p ~/send/

name=$1
list=`cat $1`

for i in $list
do
	echo $i

	# Options depending on where the images are placed
	/bin/mv -f $i.DAT IMAGEFILES/$i.DAT		# Use for Imager_grid
	#/bin/mv -f TEMPLATES/$i.RAW IMAGEFILES/$i.DAT		# Use for Imager_MG

	echo "$i" > tmp
	echo "y" >> tmp
	echo "0" >> tmp
	echo "n" >> tmp
	echo "n" >> tmp
	/usr/local/bin/Display < tmp
	convert TEMPFILE.pgm ~/send/$i.jpg
	rm TEMPFILE.pgm		# Cleaning up old files
done

exit

