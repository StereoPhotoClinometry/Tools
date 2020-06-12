# Eric E. Palmer - 10 May 2019
# Shows an image in register

id=$1
img=$2
flag=$3

if [ "$id" = "" ]
then
	echo "Error, no bigmap defined"
	echo "Usage: $0 <5char ROI> <Image2Use>"
	exit;
fi

if [ "$img" = "" ]
then
	echo "Error, no image selected"
	exit;
fi

xMap=${id}X
map=${id}W

if [ ! -e MAPFILES/$map.MAP ]
then
	echo "Error. Cannot find $map.MAP"
	exit
fi


# Ensure that the first char of the maplet id is not 0.  Register 
#		assumes that 0 means use zmap (even if there are other digits)
# 		Thus, if it is used, we relink XXXXXX
first=`echo $map | cut -c 1`
if [ "$first" == "0" ]
then
	echo "Relinking $map to XXXXXX"
	cd MAPFILES
	relink.sh $map.MAP XXXXXX.MAP
	cd ..
	map=XXXXXX
fi

# Build the script that register will read in and run
echo $img > tmpRun
echo m >> tmpRun
echo $map >> tmpRun
echo .0005 >> tmpRun

echo 8 >> tmpRun
echo m >> tmpRun
echo $map >> tmpRun
echo y >> tmpRun

# Shift and zoom the map/image
sh=`grep $img mapConfig/img-$id | cut -c 13-` 
echo Shift:  $sh

if [ "$flag" != "" ]
then
	sh=""
	echo Skipping shift
fi

# If it actuall shifted, zoom in
if [ "$sh" != "" ]
then
	echo 2 >> tmpRun
	echo $sh >> tmpRun
	echo 1 >> tmpRun
	echo .00005 >> tmpRun
fi

echo 0 >> tmpRun
echo n >> tmpRun
echo q >> tmpRun

# Run register using an older version that renders the data better
/opt/local/spc/unsup/bin/myRegister < tmpRun
#/usr/local/src/SPC/v3.0A2/bin/REGISTER < tmpRun

