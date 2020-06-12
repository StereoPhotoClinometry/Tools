#!/bin/bash
# 21 Oct 2014
#		Eric E. Palmer
# batch loads images into existing landmarks

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
	#echo "-$i $cnt"
	echo "i" >> tmpRun.txt
	echo $i >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "n" >> tmpRun.txt

	echo "e" >> tmpRun.txt
	echo "a" >> tmpRun.txt
	echo "0 45 .25 .25 0 9999" >> tmpRun.txt

	echo "u" >> tmpRun.txt
	echo "0" >> tmpRun.txt

	if [ $cnt == 40 ] 
	then
		echo "Running 40 block ($bigCnt of $total)"
		cnt=0
		echo "q" >> tmpRun.txt
		lithos < tmpRun.txt > tmpOut.txt
		echo "#" >tmpRun.txt			# empty the lithos input
		cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign
	fi

done

echo "Finish ($bigCnt of $total)"
echo "q" >> tmpRun.txt
lithos < tmpRun.txt > tmpOut.txt
cat tmpOut.txt >> tmpFull.txt		# save original output - for trackign

