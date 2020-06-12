# Creates images in batch and parallel
# Give it a list of image names in a file and it will generate the 
#		the images and save them as a template
#		Use viewImages to use them
# This runs the image generation in batch (sloppy but effective)
#!/bin/sh

file=$1

if [ "$file" == "" ]
then
	echo "Usage: $0 <filename>"
	exit
fi


which=Imager_Grid
#which=Imager_MG

mkdir -p TEMPLATES

list=`cat $file`

cnt=0
sub=0

num=`echo $list | wc -w`
for i in $list 
do
	cnt=`echo $cnt + 1 | bc`
	sub=`echo $sub + 1 | bc`
	echo $sub: $i $cnt of $num

	echo $i > tmp

	# Script adjustment for using imager_grid
	if [ "$which" == "Imager_grid" ]
	then
		echo "n" >> tmp
	else
		echo "n" >> tmp
		echo "y" >> tmp
	fi

	if [ $sub -gt 23 ]; 
	then
		$which < tmp 
		echo sub;
		sub=0;
	else
		$which < tmp &
		sleep 2;
	fi

done
