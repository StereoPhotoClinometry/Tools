# 14 Dec 2015 - Eric E. Palmer
# This prints the line right after some keyword
# Version 1.1 -- 1 Mar 16

exPath="/opt/local/spc/bin/"
mkdir -p eval

file=$1

echo "#" `date` > eval/evalOut.txt
echo "#",  $0, $vers >> eval/evalOut.txt
echo "#",  Name, Start, End, Removed | tee -a eval/evalOut.txt


if [ "$file" == "" ]
then
   list=`ls | grep OOT`
   total=`ls | grep INN | wc -l`
else
   list=`cat $file`
   total=`echo $list | wc -l`
fi

cnt=0

for i in $list 
do
	echo -n $i | tee -a  eval/evalOut.txt
	awk -f $exPath/autoEval.awk $i | tee -a eval/evalOut.txt
	cnt=`echo $cnt + 0 | bc`
done


