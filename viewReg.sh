# Eric E. Palmer - 10 May 2019
# Shows an image in register


#program="REGISTER"      # put in program version/path
#program="/usr/local/src/SPC/v3.0.2/bin/REGISTER"      # put in program version/path
program="/opt/local/spc/unsup/bin/myRegister"                # put in program version/path




id=$1

if [ "$1" = "" ]
then
	echo "Error, no bigmap defined"
	exit;
fi

xMap=${id}X
map=${id}A

if [ ! -e MAPFILES/$map.MAP ]
then
	echo "Error. Cannot find $map.MAP"
	exit
fi

# Checks to see if there is a correspondin landmark definition somehwere
#if [ -e BIGFILES/$map.LMK ]
#then
#	item=`grep M60 BIGFILES/$map.LMK | tail -1 | cut -c 1-12`
#fi

#if [ -e LMKFILES/$xMap.LMK ]
#then
#	item=`grep M60 LMKFILES/$xMap.LMK | head -1 | cut -c 1-12`
#	echo image: $item
#fi

file=nftConfig/nftBigmap-$id-A.IN
if [ ! -e $file ]
then
		echo "Error: Cannot open $file, or nft version"
		exit
fi

item=`head -2 $file | tail -1`


if [ "$item" == "" ]
then
	echo "Error, cannot find $map.LMK in BIGFILES or LMKFILES"
	echo "Do you have the version flag (A, W, Y, etc)?"
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
echo $item > tmpRun
echo m >> tmpRun
echo $map >> tmpRun
echo .0001 >> tmpRun

echo 8 >> tmpRun
echo m >> tmpRun
echo $map >> tmpRun
echo y >> tmpRun

# Check to see if there is a shift file, if so, use those values
#		and zoom in
sh=`grep $id nftConfig/shift | cut -c 7-` 

theFile=nftConfig/nftBigmap-$id-A.IN
line=`head -4 $theFile| tail -1`
bestRes=`echo $line | awk '{print $1}' `
echo "bestRes: " $bestRes
scale=`echo "scale=7; $bestRes / 4" | bc `
echo "scale: " $scale

# If it actuall shifted, zoom in
if [ "$sh" != "" ]
then
	echo 2 >> tmpRun
	echo $sh >> tmpRun
	echo 1 >> tmpRun
	echo $scale >> tmpRun
	#echo .00003 >> tmpRun
fi

echo 0 >> tmpRun
echo n >> tmpRun
echo q >> tmpRun

# Run register using an older version that renders the data better
/opt/local/spc/unsup/bin/goodRegister < tmpRun
#/usr/local/src/SPC/v3.0A2/bin/REGISTER < tmpRun

