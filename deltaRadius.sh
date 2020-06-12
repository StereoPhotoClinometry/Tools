# Eric E. Palmer - 20 Nov 2018
# Calculates the radius change between the landmark vector and the shape model
# Arguments
#   Either a landmark or a file of landmarks
#   If none, then uses the SPC list of landmarks, LMRKLIST.TXT

arg=$1
d=`date`
echo "# $0" > evalResults.txt
echo "# $d" >> evalResults.txt


myPath="/opt/local/spc/bin"

# No argument defined
if [ "$arg" == "" ]
then
	echo "# Using LMRKLIST.TXT"   | tee -a  evalResults.txt
	list=`cat LMRKLIST.TXT`
else


	if [ -e $arg ]
	then
		echo "# Found $arg file, using files"   | tee -a  evalResults.txt
		list=`cat $arg`
	else
		echo "# Single landmark: $arg"   | tee -a  evalResults.txt
		list="$arg"
	fi

fi

echo "# Lat	Lon	lmk	shape	delta"   | tee -a  evalResults.txt

for item in $list
do

	if [ "$item" == "END" ]
   then
	   break;
   fi

	#echo $item
	echo "i" > tmpRun.txt
	echo "$item" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "n" >> tmpRun.txt
	echo "m" >> tmpRun.txt
	echo "q" >> tmpRun.txt

	lithos < tmpRun.txt > tmpOut.txt
	echo -n "$item	"  | tee -a evalResults.txt
	awk -f $myPath/deltaRadius.awk  tmpOut.txt | tee -a evalResults.txt

done






