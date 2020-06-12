# 13 Dec 2015 - Eric E. Palmer
# Just takes a list of images, converts them into jpg and 
#		puts them into ~/send/

file=$1

if [ "$file" == "" ]
then
	echo "No file"
	exit 
fi

d=`date`
echo "# $d" > evalOut.txt


list=`cat $file`

for i in $list
do

	if [ -e $i ] 
	then
		/opt/local/spc/bin/detectLimbWidth $i | tee -a evalOut.txt
	else
		/opt/local/spc/bin/detectLimbWidth $i.pgm | tee -a evalOut.txt
	fi

done

