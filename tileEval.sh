# 14 Jan 2016 - Eric E. Palmer
# Parses the OOT files from make_scriptP/lithosP
#		It shows # of landmarks without overlap and/or correlated images

file=$1
version=1.1
path="/opt/local/spc/bin/"
mkdir -p eval

echo "#" `date` > eval/evalOut.txt
echo "#",  $0, $vers >> eval/evalOut.txt
#echo "#" `date` > eval/evalRedo.txt
#echo "#",  $0, $vers >> eval/evalRedo.txt
echo "#" `date` > eval/evalLow.txt
echo "#",  $0, $vers >> eval/evalLow.txt
echo "#" `date` > eval/evalRemoved.txt
echo "#",  $0, $vers >> eval/evalRemoved.txt
echo "#" `date` > eval/evalRunning.txt
echo "#",  $0, $vers >> eval/evalRunning.txt
echo "#" `date` > eval/evalDeleted.txt
echo "#",  $0, $vers >> eval/evalDeleted.txt


if [ "$file" == "" ]
then
	list=`ls *OOT`
	total=`ls *INN | wc -l`
else
	list=`cat $file`
	total=`echo $list | wc -l`
fi


#echo 'c'
cnt=0
run=0
deleted=0

for i in $list 
do

	isDone=`grep DONE $i`
	if [ "$isDone" == "" ]
	then
		run=`echo $run + 1 | bc`
		echo $i >> eval/evalRunning.txt
		continue
	fi

	del=`grep deleted $i`
   if [ "$del" == "" ]
   then
		awk -v id=$i -f $path/tileEval.awk $i | tee -a eval/evalOut.txt
		grep removed $i >> eval/evalTmp.txt
	else
      part=`echo $i | cut -c 1-3`
      where=`head -4  $part.INN | tail -1`
      #where=`head -4 426.INN $part.INN | tail -1`
      echo -n "	$i Deleted: " | tee -a  eval/evalOut.txt
      echo "$where" | tee -a  eval/evalDeleted.txt
		deleted=`echo $deleted + 1 | bc`
	fi
	cnt=`echo $cnt + 1 | bc`
done

awk -f $path/tileEval.awk2 eval/evalTmp.txt >> eval/evalRemoved.txt

echo "Evaluated $cnt "
echo "Total $total"
echo "Running: $run"
echo "Deleted: $deleted"
#grep -e NO -e \( eval/evalOut.txt >> eval/evalRedo.txt		# not checking correlation for this script
grep Img eval/evalOut.txt >> eval/evalLow.txt
