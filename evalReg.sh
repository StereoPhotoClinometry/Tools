#!/bin/bash
# 19 Jan 2015
#		Eric E. Palmer
# Runs register on the whole list and takes the ppm and saves it

# Currently, use support/eval-list
file=$1
#file=support/eval-list


if [ "$file" == "-m" ] 
then
	file=$2
	map=1
else	
	map=0
fi


if [ -z $file ]; then
	echo "Please select a file name of images to run"
	echo "Usage: $0 [-m] <file>"
	exit
fi

program="REGISTER"		# put in program version/path
program="/usr/local/src/SPC/v3.0.2/bin/REGISTER"		# put in program version/path
program="/opt/local/spc/unsup/bin/myRegister"                # put in program version/path

mkdir -p tmpDir

list=`grep -v "#" $file | cut -c 1-13`
bigCnt=0
total=`wc -l $file`


for i in $list 
do

	# Skip tucked images
	first=`echo $i | cut -c 1`
	if [ "$first" == "!" ]
	then
		continue
	fi

	# stop when END is reached
	if [ "$i" == "END" ]
	then
		break
	fi

	bigCnt=`echo $bigCnt + 1 | bc`
	echo $i > tmpRun.txt

	if [ "$map" == "1" ]
	then
		echo "m" >> tmpRun.txt
		echo "0" >> tmpRun.txt
		echo ".0001" >> tmpRun.txt
		echo "a" >> tmpRun.txt
		echo "8" >> tmpRun.txt
		echo "m" >> tmpRun.txt
		echo "y" >> tmpRun.txt
		echo "0" >> tmpRun.txt
	else
		echo "s" >> tmpRun.txt
		echo ".001" >> tmpRun.txt
	fi


	# Try autoalignment for correlation score
	echo "3" >> tmpRun.txt
	echo "Y" >> tmpRun.txt
	echo "XSTOP" >> tmpRun.txt

	# End
	echo "0" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "q" >> tmpRun.txt

	echo "Running $i ($bigCnt of $total)"
	$program < tmpRun.txt > tmpDir/$i.txt

	convert TEMPFILE.ppm ~/send/limbC-$i.jpg
	convert TEMPFILE.pgm ~/send/limb-$i.jpg
done


