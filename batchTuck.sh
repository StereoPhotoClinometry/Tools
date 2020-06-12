#!/bin/bash
# 21 Oct 2014
#		Eric E. Palmer
# batch loads images into existing landmarks

file=$1

date > tmpFull.txt
echo "# Batch" > tmpRun

list=`cat $file`
cnt=0
bigCnt=0
total=`wc -l $file`

for i in $list 
do

	ans=`grep $i PICTLIST.TXT | cut -c 1`
	if [ "$ans" == "!" ]
	then
		echo $i $ans "Already tucked, Found !"
		continue;
	fi

	cnt=`echo $cnt + 1 | bc`
	echo $i "  " 
	echo "p" >> tmpRun
	echo $i >> tmpRun
	echo "1" >> tmpRun

done

echo "q" >> tmpRun
echo ""
echo "Finished -- Now run ..."
echo "lithos < tmpRun | tee -a  tmpFull.txt"

