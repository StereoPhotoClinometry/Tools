Header="
# USAGE: sh batchCorrelation.sh [-option] outpath mapfile(s) truthmap
#     -o   Use this followed by 'outpath' to
#          specify a unique output destination.
#          By default the output is sent to the
#          current working directory.
#
#     -h   Use this to print usage directions
#          to StdOut. (Prints this header)
#
#     -v   Use this to only output current
#          version number and exit. By default
#          the version will be sent to StdOut
#          at the beginning of each use.
#
########################################################################
"


##~AUTHOR INFO~##
# By Tanner Campbell
# In support of the OSIRIS-REx mission 2016
##

##~VERSION NOTES~##
# 0.0 - batchCor.sh personal usage / wiki
# 1.0 - CM ready
#     - changed name
#     - absorbed batchPGM.sh
#     - added comments
#     - included file modifications
#     - added support for single map/bigmap
# 1.1 - updated to mpXcorr.py
#     - used SPC/bin/ paths
# 1.2 - linked truth to temp name WWXXYY (disambiguation)
# 1.2.1 - updated initialization options (command line arguments)
# 1.2.2 - changed varriable assignments
# 1.3 - fixed 1 px center of map error
##

##~FILE DEPENDENCIES~##
# User specified:
#            - outpath, optional output directory (when you don't own
#                       the working directory)
#            - mapfile(s), name of mapfile (including .MAP) or list
#                          of mapfiles (without .MAP) to be processed
#            - truthmap, absolute or relative path to the truth mapfile
#                        (with .MAP)
#
# Required:
#            - BIGLIST.TXT, file will be backed up, modified, then 
#                           returned to original state
#            - MAPFILES/, symbolic link to truthmap will be made here,
#                         then removed
#            - newFind, standalone lithos "find" routine. Can be replaced
#                       with lithos (see wiki)
#            - mpXcorr.py, normalized cross-correlation python script
##

##~SPC DEPENDENCIES~##
# showmap
# dumpMapHeaders
##


####################~INITIALIZE~####################
version=1.3

opt=$1
out=false

spcpth=/opt/local/spc/bin
cp=COROUT
opath=$PWD


if [[ $# == 0 ]]
then
        echo "Input single mapfile path/name or list of maplets."
        read file1

        echo "Input path/name of truth map."
        read file2
elif [[ $# == 2 && $opt != "-"* ]]
then
	file1=$1
	file2=$2
elif [[ $opt == "-"* ]]
then
	if [ $opt == '-v' ]
	then
		echo "Version: "$version
		exit
	elif [ $opt == '-h' ]
	then
		echo "$Header"
		exit
	elif [ $opt == '-o' ]
	then
		out=true

		opath=$2
		cp=$opath/$cp

		file1=$3
		file2=$4
	fi
else
	echo "Try again."
	exit
fi

echo "batchCorrelation.sh version: "$version
echo "Map list: "$file1
echo "Truth map: "$file2
echo "Output directory: "$opath
echo " "

if [[ $file1 == *".MAP" ]]
then 
	list=${file1:(-10):(6)}
else
	list=`cat $file1`
fi

mkdir -p $cp

cdir=$PWD

if [ $out == 'true' ]
then
        ln -s $cdir/MAPFILES $opath/MAPFILES
fi

cd $opath

tmap=${file2:(-10):(6)}
fmap=WWXXYY

ln -s $file2 MAPFILES/$fmap.MAP
showmap <<< $fmap
mv $fmap.pgm $cp/$tmap.pgm

cp $cdir/BIGLIST.TXT $opath/bak.BIGLIST.TXT
echo $fmap > BIGLIST.TXT
cat bak.BIGLIST.TXT >> BIGLIST.TXT


####################~CORRELATION~####################
rm -f locations.txt

for i in $list
do
	showmap <<< $i
	mv $i.pgm $cp/

	Qsize=`$spcpth/dumpMapHeaders <<< $i | awk '/Qsize/{print $3}'`
	# mid=$((Qsize+1))

	echo "m" > tmpf
	echo $i >> tmpf
	echo $Qsize $Qsize >> tmpf

	read x y <<< $($spcpth/newFind < tmpf | awk "/$fmap/"'{print $3, $4}')
	
	python $spcpth/mpXcorr.py $cp/$i.pgm $cp/$tmap.pgm > $cp/$i.txt

	read tx ty <<< $(awk '/match/{print $8, $9}' $cp/$i.txt)
	dx=`echo "$tx-$x" | bc`
	dy=`echo "$ty-$y" | bc`

	cor=`awk '/Max/{print $4}' $cp/$i.txt`

	printf "$i $x $y $dx $dy $cor\n" >> locations.txt
done


####################~CLEAN~####################
rm tmpf
rm MAPFILES/$fmap.MAP
rm BIGLIST.TXT

mv bak.BIGLIST.TXT BIGLIST.TXT	
