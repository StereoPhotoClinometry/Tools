#!/bin/bash
# 30 Oct 2014
#		Eric E. Palmer
# batch deleted landmarks 

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
	echo -n $i " "
	cnt=`echo $cnt + 1 | bc`
	bigCnt=`echo $bigCnt + 1 | bc`
	#echo "-$i $cnt"
	echo "d" >> tmpRun.txt
	echo $i >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "y" >> tmpRun.txt

done
#exit

echo "Finish ($bigCnt of $total)"
echo "q" >> tmpRun.txt
echo "lithos < tmpRun.txt | tee tmpOut.txt"

