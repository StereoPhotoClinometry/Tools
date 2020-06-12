#!/bin/bash
# 27 Oct 2014
#		Eric E. Palmer
# Changes the first character of the landmark name

file=$1

date > batchResults.txt
echo "# Batch" > tmpRun.txt

list=`grep -v \# $file`
cnt=0
total=`wc -l $file`

for i in $list 
do
	cnt=`echo $cnt + 1 | bc`

	ch=`echo $i | cut -c 1`

	if [ "$ch" == "" ]
	then
		continue
	fi

	if [ "$i" == "END" ]
	then
		break;
	fi

	echo "f" >> tmpRun.txt
	echo "p" >> tmpRun.txt
	echo "$i" >> tmpRun.txt
	echo "512 512" >> tmpRun.txt
done

echo "q" >> tmpRun.txt

lithos < tmpRun.txt | tee  tmpOut.txt
grep Lat  tmpOut.txt | cut -c 17- | tee batchResults.txt


