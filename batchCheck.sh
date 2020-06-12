#!/bin/bash
# 25 May 2014
#		Eric E. Palmer
# Builds a script for batch lithos

file=$1

if [ -z $file ]; then
   echo "Please select a file name of images to run"
   exit
fi


date > tmpFull.txt
echo "# Batch" > tmpRun.txt
program="lithos"		# put in program version/path

list=`cat $file`
cnt=0
bigCnt=0
total=`wc -l $file`

for i in $list 
do
	cnt=`echo $cnt + 1 | bc`
	bigCnt=`echo $bigCnt + 1 | bc`
	#echo "-$i $cnt"
	echo "i" >> tmpRun.txt
	echo $i >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "n" >> tmpRun.txt

	echo "0" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	echo "0" >> tmpRun.txt

	echo "1" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	echo "1" >> tmpRun.txt

	echo "n" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	echo "n" >> tmpRun.txt

	if [ $cnt == 1 ] 
	then
		echo "Running $i ($bigCnt of $total)"
		cnt=0
		echo "q" >> tmpRun.txt
		$program < tmpRun.txt > tmpOut.txt
		echo "#" >tmpRun.txt			# empty the lithos input
		cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign
		convert LMRK_DISPLAY1.pgm ~/send/$i.jpg
	fi

done

		echo "q" >> tmpRun.txt
		$program < tmpRun.txt > tmpOut.txt
		echo "#" >tmpRun.txt			# empty the lithos input
		cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign

awk -f support/track.awk tmpFull.txt > tmpResults.txt
awk -f support/coords.awk tmpFull.txt > tmpLat.txt

