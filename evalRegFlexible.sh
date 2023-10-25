#!/bin/bash
# 19 Jan 2015
#		Eric E. Palmer
# Runs register on the whole list and takes the ppm and saves it

# 28 December 2020
#      Terik Daly
# Commented out lines 31 and 32 to make sure that it finds
# the register specified by the user's $PATH

# 6 October 2023
#      Terik Daly
# Created this by copying evalReg.sh and making the scale used in register an argument
# instead of a hard-coded value. I also made the folder where the images get saved to
# an argument.

# Example. This will run all of the images in listOfPics.txt through the script and 
# use a scale of 10 km in register. It puts the images into a folder in the working 
# directory called evalRegPics. The script will make the folder if it doesn't already 
# exist. The path is relative! The image list needs to be in the format used make
# make_scriptR.in (i.e., a leading space, followed by the sumfile name, with an END)

# support/evalRegFlexible.sh listOfPics.txt 10 evalRegPics
file=${1}
scale=${2}
folder=${3}


if [ -d "${3}" ]
then
    echo "Directory ${3} exists."
else
    echo "Error: Directory ${3} does not exist - creating it now."
    mkdir ${3}
fi

# note from Terik = I don't fully understand what this is doing and haven't
# used it, so I am commenting it out so that these variables don't stomp
# on what I define above.
#if [ "$file" == "-m" ] 
#then
#	file=$2
#	map=1
#else	
#	map=0
#fi


if [ -z $file ]; then
	echo "Please select a file name of images to run"
	echo "Usage: $0 [-m] <file>"
	exit
fi

program="REGISTER"		# put in program version/path
#program="/usr/local/src/SPC/v3.0.2/bin/REGISTER"		# put in program version/path
#program="/opt/local/spc/unsup/bin/myRegister"                # put in program version/path

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
		echo ${2} >> tmpRun.txt
		echo "a" >> tmpRun.txt
		echo "8" >> tmpRun.txt
		echo "m" >> tmpRun.txt
		echo "y" >> tmpRun.txt
		echo "0" >> tmpRun.txt
	else
		echo "s" >> tmpRun.txt
		echo ${2} >> tmpRun.txt
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

	convert TEMPFILE.ppm ./${3}/limbC-$i.jpg
	convert TEMPFILE.pgm ./${3}/limb-$i.jpg
done


