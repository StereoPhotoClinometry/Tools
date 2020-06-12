# 14 Jan 2016 - Eric E. Palmer
# Parses the OOT files from make_scriptP/lithosP
#		It shows # of landmarks without overlap and/or correlated images
# v1.1 - 1 Mar.  Standardizes the name.  Added in the counting of images
# v1.2 - Sep 17 - path update
# v1.3 - Oct 26 2019 - added path eval/

file=$1
vers=1.3
path="/opt/local/spc/bin/"
mkdir -p eval

echo "#" `date` > eval/evalOut.txt
echo "#",  $0, $vers >> eval/evalOut.txt
#echo "#" `date` > eval/evalImg.txt
#echo "#",  $0, $vers >> eval/evalImg.txt
echo "#" `date` > eval/evalRedo.txt
echo "#",  $0, $vers >> eval/evalRedo.txt
#echo "#" `date` > eval/evalLow.txt
#echo "#",  $0, $vers >> eval/evalLow.txt


if [ "$file" == "" ]
then
	list=`ls | grep .OOT`
	total=`ls | grep .INN | wc -l`
else
	list=`cat $file`
	total=`echo $list | wc -l`
fi


#echo 'c'
cnt=0

for i in $list 
do
	awk -v str=$str -v id=$i -f $path/iterateEval.awk $i | tee -a eval/evalOut.txt
	cnt=`echo $cnt + 1 | bc`
done

# I don't think I want this anymore
#awk -f $path/tileEval.awk2 eval/evalOut.txt | tee -a eval/evalImg.txt


echo Evaluated $cnt 
echo Total $total
grep -e NOCORR eval/evalOut.txt >> eval/evalRedo.txt
#grep Img eval/evalOut.txt >> eval/evalLow.txt
