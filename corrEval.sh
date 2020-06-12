# Eric E. Palmer - 23 Apr 2012
# Reads the OOT files and generates statistics

whichRez=$1
mkdir -p eval

p=`pwd`
d=`date`
echo "# $p" > eval/evalResults
echo "# $d" >> eval/evalResults

list=`ls | grep OOT`
base=/opt/local/spc/bin/

echo "#name	Res	Lat	Lon	Min	Average	SigmaS	%Pass"
sSum=0
sum=0
count=0
above=0
for item in $list
do
	short=`echo $item | cut -c 1-6`
	if [ -e MAPINFO.TXT ] 
	then
		geo=`grep  $short MAPINFO.TXT | cut -c 23-45`
		rez=`grep  $short MAPINFO.TXT | cut -c 11-16`
		if [ "$whichRez" != "$rez" ]
		then
			if [ "$whichRez" != "" ]
			then
				continue
			fi
		fi
	fi

	# evaluate the OOT file
	awk -f $base/landmarkOOT.awk $item > tmpOut
	ans=`awk -f $base/landmarkOOT.awk $item`

	# If the geo coordinates are missing, fill it with 0
	if [ "$geo" == "" ]
	then
		geo=" 0     0       0     "
	fi

	# Pull data from the awk response
	sig=`cut -c 29-33 tmpOut`
	min=`cut -c 1-6 tmpOut`
	avg=`cut -c 15-19 tmpOut`
	pass=`cut -c 34-43 tmpOut`

	# do math
	sSum=`echo $sSum + $sig | bc`
	sum=`echo $sum + $avg | bc`
	count=`echo $count + 1 | bc`
	echo $short	$rez	$geo	$min  "   " $avg " "  $sig " "  $pass| tee -a eval/evalResults
	tmp=`echo "$sig * 100 / 1" | bc`
	if [ $tmp -ge 200 ]
	then
		above=`echo $above + 1 | bc`
	fi
	geo=""
done


echo "# Average " `echo $sum / $count | bc -l` | tee -a eval/evalResults
echo "# Average Sig " `echo $sSum / $count | bc -l` | tee -a eval/evalResults
echo "# Above 2 Sigma Score $above"  | tee -a eval/evalResults
echo "#" count $count | tee -a eval/evalResults
