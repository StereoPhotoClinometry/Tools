Header="
# USAGE: sh batchImXcorr.sh [-option] imagefile(s) mapfile(s)
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
# 0.0 - hack, personal usage
# 1.0 - first release
# 1.1 - changed input order (again)
#     - changed expected truth image location
# 1.2 - added support for custom cropping in imagefile list
##

##~FILE DEPENDENCIES~##
# User specified:
#            - imagefile(s), single .pgm image or list of images for correlation
#                            this may also contain corners for a cropping box 
#                            following the image name as x1 x2 y1 y2 (x is line, y is pixel)
#            - mapfile(s), single mapfile or list of mapfiles to render images from
#
# Required:
#            - MAPFILES/, expected location for mapfile(s)
#            - SUMFILES/, expected location for imagefile(s) sumfile
#            - truthImg/, expected location for imagefile(s)
#            - imXcorr.py, normalized cross-correlation python script
##

##~SPC DEPENDENCIES~##
# Imager_MG
##


####################~INITIALIZE~####################
version=1.2

opt=$1

spcpth=/opt/local/spc/bin
cpth=COROUT
impth=PGMFILES

if [[ $# == 0 ]]
then
        echo "Please input image or list of images."
        read file1

	echo "Please input name of mapfile or list of mapfiles."
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
	fi
else
	echo "Try again."
	exit
fi

echo "batchImXcorr.sh version: "$version
echo "Image (list): "$file1
echo "Mapfile(s): "$file2
echo " "

if [[ $file1 == *".pgm" ]]
then
	list1=${file1:(-16):(12)}
else
	f1L=`cat $file1 | wc -l`
	f1W=`cat $file1 | wc -w`

	if [ $f1L -eq $f1W ]
	then
		flagc=False

		list1=`cat $file1`
	else
		flagc=True

		list1=`cat $file1 | cut -d ' ' -f 1`

		cropl=`cat $file1 | cut -d ' ' -f 2-`
		cropa=($cropl)
	fi
fi

if [[ $file2 == *".MAP" ]]
then
        list2=${file2:(-10):(6)}
else
        list2=`cat $file2`
fi

mkdir -p $cpth $impth 

if [ -e MAPLIST.TXT ]
then
	cp MAPLIST.TXT bak.MAPLIST.TXT
fi


####################~CREATE IMAGES~####################
for i in $list2
do
	echo $i > MAPLIST.TXT
	echo "END" >> MAPLIST.TXT

	for j in $list1
	do
		echo $j > tmp.in
		echo "n" >> tmp.in

		Imager_MG < tmp.in

		mv TEMPFILE.pgm $impth/${j}_${i}.pgm
	done
done


####################~CORRELATION~####################

for i in $list2
do
	rm -f $i.txt
	cnt=0

	for j in $list1
	do
		if [ $flagc == 'True' ]
		then
			if [ $j == ${cropa[$cnt]} ]
			then
				python $spcpth/imXcorr.py $impth/${j}_${i}.pgm truthImg/$j.pgm > $cpth/${j}_${i}.txt
				
				cnt=$((cnt+1))
			else
				python $spcpth/imXcorr.py -c ${cropa[@]:cnt:$((cnt+4))} $impth/${j}_${i}.pgm truthImg/$j.pgm > $cpth/${j}_${i}.txt

				cnt=$((cnt+4))
			fi
		else
			python $spcpth/imXcorr.py $impth/${j}_${i}.pgm truthImg/$j.pgm > $cpth/${j}_${i}.txt
		fi

		cor=`awk '/Max/{print $4}' $cpth/${j}_${i}.txt`

		printf "\t$j $cor\n" >> $i.txt
	done
done


####################~CLEAN~####################
rm tmp.in

if [ -e bak.MAPLIST.TXT ]
then
	mv bak.MAPLIST.TXT MAPLIST.TXT
fi

