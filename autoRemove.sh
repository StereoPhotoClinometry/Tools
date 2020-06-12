#!/bin/bash
# 30 Oct 2014
#		Eric E. Palmer
# batch removes all landmarks from iamges

file=$1

date > tmpFull.txt

list=`cat $file`
cnt=0
bigCnt=0
total=`wc -l $file`

for i in $list 
do
	cnt=`echo $cnt + 1 | bc`
	bigCnt=`echo $bigCnt + 1 | bc`
	#echo "-$i $cnt"
	echo $i > tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "a" >> tmpRun.txt
	echo "1 1 1 0 5" >> tmpRun.txt

	echo "q" >> tmpRun.txt
	autoregister < tmpRun.txt > tmpOut.txt
	cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign

done

echo "Finish ($bigCnt of $total)"

