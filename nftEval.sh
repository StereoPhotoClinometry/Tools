# Eric E. Palmer - 1 May 2019
# 		Runs a bunch of evaluation stuff
# 		Don't add suffix -- use W

echo "##nftEval.sh"
id=$1
extraBin=/opt/local/spc/unsup/unsup_v3_1B2/bin/



if [ "$id" == "" ]
then
	echo "Error, no id listed"
	exit;
fi

#  Check to see that we are not expecting different version calculations
sub=`echo $id | cut -c 6`
if [ "$sub" != "" ]
then
	echo "######### Error "
	echo "Don't use all 6 char for the id.  This assumes the use of W and Y"
	exit
fi

# Build a starting bigmap.  Based on the working nft feature def
map=${id}A
file="nftConfig/nftBigmap-$id-A.IN"

line=`head -4 $file| tail -1`
GSD=`echo $line | awk '{print $1}' `
Q=`echo $line | awk '{print $2}' `

#GSD=`echo $line | cut -c 1-10`
#Q=`echo $line | cut -c 12-15`
echo "gsd $GSD"
echo "Q $Q"


echo file $file

if [ ! -e $file  ]
then
	echo "Error, cannot find the file $file, or the nft one either"
	exit;
fi

# Set variables
name=${id}Z			# this is maplet name
echo "Name $name"



# Update the reference map -- needed for the next step (bigMapRef)
if [ ! -e "MAPFILES/$map.MAP" ]
then
	bigmap < $file
fi



# Build a bigmap using the higher score level bigMapRef
echo $map > tmpRun
cat $file >> tmpRun
bigMapRef < tmpRun


# Link the bigmap to XXXXXX
cd MAPFILES
relink.sh $map.MAP XXXXXX.MAP
cd ..


# Script to build a ref landmark
echo c > tmpRun
echo $name >> tmpRun
echo m >> tmpRun
echo XXXXXX >> tmpRun
echo $Q $Q>> tmpRun
echo $GSD 49 >> tmpRun

echo i >> tmpRun
echo $name >> tmpRun
echo y >> tmpRun
echo .5 >> tmpRun
echo n >> tmpRun


echo b >> tmpRun
echo n >> tmpRun
echo XXXXXX >> tmpRun

echo e >> tmpRun
echo n >> tmpRun
echo 0 50 .25 .25 0 3 >> tmpRun

echo 1 >> tmpRun
echo 0 >> tmpRun
echo 3 >> tmpRun
echo n >> tmpRun
echo 0 >> tmpRun
echo y >> tmpRun
echo 1 >> tmpRun
echo 0 >> tmpRun
echo 1 >> tmpRun
echo n >> tmpRun
echo 0 >> tmpRun
echo y >> tmpRun

echo e >> tmpRun
echo m >> tmpRun
echo 0 >> tmpRun

echo u >> tmpRun
echo 1 >> tmpRun
echo q >> tmpRun


# Build the landmark
$extraBin/LITHOS < tmpRun 



# Get processing stats
echo i > tmpRun
echo $name >> tmpRun
echo n >> tmpRun
echo n >> tmpRun

echo e >> tmpRun
echo q >> tmpRun
echo q >> tmpRun

$extraBin/LITHOS < tmpRun | tee tmpOut
line=`wc -l tmpOut | cut -c -9`

remove=`echo $line - 30 | bc`
#echo "remove: " $remove
tail -$remove tmpOut > t2
remove=`echo $line - 32 - 30 | bc`
#echo $remove
echo "# List of images for mapletZ normal" > evalNote
head -$remove t2 >> evalNote


echo "# MAPINFO for USED_MAPS" >> evalNote
head -1 MAPINFO.TXT >> evalNote
grep -f USED_MAPS.TXT MAPINFO.TXT >> evalNote

echo i > tmpRun
echo $name >> tmpRun
echo n >> tmpRun
echo n >> tmpRun

echo 0 >> tmpRun
echo 0 >> tmpRun
echo 1 >> tmpRun
echo q >> tmpRun
echo q >> tmpRun

echo "# RMS Brightness Residual" >> evalNote
$extraBin/LITHOS < tmpRun | tee tmpOut
grep brightness tmpOut >> evalNote

echo "# Correlation for mapletZ" >> evalNote
echo i > tmpRun
echo $name >> tmpRun
echo n >> tmpRun
echo n >> tmpRun

echo 1 >> tmpRun
echo 0 >> tmpRun
echo 1 >> tmpRun
echo n >> tmpRun
echo 0 >> tmpRun
echo n >> tmpRun

echo q >> tmpRun
$extraBin/LITHOS < tmpRun | tee tmpOut
grep P6 tmpOut | grep -v check > t2


line=`wc -l t2 | cut -c -9`
echo line $line
remove=`echo $line / 2 | bc`
echo remove $remove
tail -$remove t2 >> evalNote

# Print some useful output

echo > evalResults-$id
echo >> evalResults-$id
echo "###################" >> evalResults-$id
echo "##### $id #######" >> evalResults-$id
echo "###################" >> evalResults-$id

echo $id >> evalResults-$id

# Get cardinal output
echo $name >> evalResults-$id
cardinalCS CSPLOT.TXT | tee -a evalResults-$id
convert CSPLOT.ppm ~/send/cs-$name.jpg
tail -2 SIGMAS.TXT  | head -1 >> evalResults-$id


# Get score
landmarkEval.sh $name | tee -a evalResults-$id




# Delete the landmark
echo d > tmpRun
echo $name >> tmpRun
echo 1 >> tmpRun
echo y >> tmpRun
echo q >> tmpRun

lithos < tmpRun

