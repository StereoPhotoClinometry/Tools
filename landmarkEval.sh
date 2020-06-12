# Eric E. Palmer - 22 Apr 2019
# This takes a landmark and runs lithos to get the average 
#		correlation score

echo "## landmarkEval.sh"
base=/opt/local/spc/bin/

extraBin=/opt/local/spc/unsup/unsup_v3_1B2/bin/

item=$1

if [ "$item" == "" ]
then
	echo "Error - no maplet selected"
	echo "Usage: $0 <maplet-6char>"
	exit
fi

echo "# name	min     max     avg     stdev   sigmaScore"

#Build the input script
echo "i" > tmpRun
echo $item >> tmpRun
echo "n" >> tmpRun
echo "n" >> tmpRun

echo "1" >> tmpRun
echo "0" >> tmpRun
echo "1" >> tmpRun
echo "n" >> tmpRun
echo "0" >> tmpRun
echo "n" >> tmpRun

echo "0" >> tmpRun
echo "0" >> tmpRun
echo "1" >> tmpRun


echo "e" >> tmpRun
echo "q" >> tmpRun

echo "q" >> tmpRun



$extraBin/LITHOS < tmpRun > tmpOut
echo -n $item " "

convert LMRK_DISPLAY1.pgm ~/send/$item.jpg

awk -f $base/landmarkEval.awk tmpOut


