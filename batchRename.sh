#!/bin/bash
# 27 Oct 2014
#		Eric E. Palmer
# Changes the first character of the landmark name

file=$1

date > batchResults.txt
date > tmpFull.txt
echo "# Batch" > tmpRun.txt

list=`cat $file`
cnt=0
bigCnt=0
total=`wc -l $file`

for i in $list 
do
	cnt=`echo $cnt + 1 | bc`
	bigCnt=`echo $bigCnt + 1 | bc`

	echo "r" >> tmpRun.txt
	echo "$i" >> tmpRun.txt
	short=`echo $i | cut -c 3-6`
	newName="KK$short"
	echo $newName >> tmpRun.txt
	echo "y" >> tmpRun.txt
done

echo "Finish ($bigCnt of $total)"
echo "q" >> tmpRun.txt
lithos < tmpRun.txt > tmpOut.txt
cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign

