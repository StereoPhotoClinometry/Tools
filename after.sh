# 14 Dec 2015 - Eric E. Palmer
# This prints the line right after some keyword

str=$1
file=$2

date > tmpOut

if [ "$str" == "" ]
then
	echo "Usage:  after.sh <string> <filelist>"
	exit
fi

if [ "$file" == "" ]
then
	echo "Usage:  after.sh <string> <filelist>"
	exit
fi

list=`cat $file`
cnt=0

for i in $list 
do
	echo -n $i >> tmpOut
	awk -v str=$str -f support/after.awk $i >> tmpOut
	cnt=`echo $cnt + 0 | bc`


done

grep -v "NoCorr" tmpOut > goodList
grep "NoCorr" tmpOut > badList

