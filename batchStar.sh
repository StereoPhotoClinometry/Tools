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

	echo "i" >> tmpRun.txt
	echo "$i" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	echo "a" >> tmpRun.txt
	echo "u" >> tmpRun.txt
	echo "1" >> tmpRun.txt
done

echo "Finish ($bigCnt of $total)"
echo "q" >> tmpRun.txt
lithos < tmpRun.txt > tmpOut.txt
cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign

