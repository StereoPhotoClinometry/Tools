#!/bin/bash

# 7 Mar 2016 - Eric E. Palmer
# Gets the pgm and calculates how many black pixels there are.  

echo "#" `date` > evalOut.txt
echo "#",  $0, $vers >> evalOut.txt
echo "#" `date` > evalBlank.txt
echo "#",  $0, $vers >> evalBlank.txt
echo "#" `date` > evalNotBlank.txt
echo "#",  $0, $vers >> evalNotBlank.txt
echo "#" `date` > evalTuck.txt
echo "#",  $0, $vers >> evalTuck.txt
echo > tmp


file=$1
vers=1.0

if [ "$file" == "" ]
then
	echo "usage: $0 <list-o-pictures>"
	exit
else
	list=`grep -v "#" $file | cut -c 1-13`
fi


cnt=0
num=0
for item in $list 
do
	echo $item > tmpRun.txt
	echo "y" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	/usr/local/bin/Display < tmpRun.txt >> evalOut.txt
	val=`/opt/local/spc/bin/processEval`
	echo $item $val "($cnt)"  | tee -a evalOut.txt
	echo $item $val  >> tmp
	cnt=`echo $cnt + 1 | bc`

	if [ "$val" == "100.000" ]
	then
		echo "################### dump" | tee -a evalOut.txt
		echo "p" >> evalTuck.txt
		echo $item >> evalTuck.txt
		echo "1" >> evalTuck.txt
		num=`echo $num + 1 | bc`
		echo $item >> evalBlank.txt
	else
		echo $item >> evalNotBlank.txt
	fi

done

#sort -n -k 2 tmp >> evalBlank.txt

echo "#### $num images were found to be blank ####"
echo
echo "#### Copy and paste if desired ####"
echo "q" >> evalTuck.txt
echo "lithos < evalTuck.txt"
