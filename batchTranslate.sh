# Batch optimize translate
# Eric E. Palmer - 25 March 2016
version=1.0
exPath="/usr/local/altwg-2014.09.05-macosx-x64/bin"
echo "# `date`" > alignOut.txt
echo "# $0" >> alignOut.txt
echo "# `date`" > alignEval.txt
echo "# $0 $version" >> alignEval.txt

model="EVAL21"
model=$1

if [ "$model" == "" ]
then
	echo "Usage: $0 <model name>.MAP  (don't include .MAP)"
	exit
fi

baseX=0.0021409559
baseY=0.0005537315
baseZ=-.0004585998

stepX=`echo $baseX *.0200000 | bc`
stepY=`echo $baseY *.0200000 | bc`
stepZ=`echo $baseZ *.0200000 | bc`

stepX=`echo .0001000 | bc`			# 10cm
stepY=`echo .0001000 | bc`
stepZ=`echo .0001000 | bc`
echo "step $stepX, $stepY, $stepZ"

startX=`echo $baseX - 5.00 \* $stepX | bc`
startY=`echo $baseY - 5.00 \* $stepY | bc`
startZ=`echo $baseZ - 5.00 \* $stepZ | bc`
echo "start $startX, $startY, $startZ"

dx=$startX
dy=$startY
dz=$startZ

countX=0
while [ "$countX" -lt "10" ]
do
	dx=`echo $dx + $stepX | bc`
	echo $dx
	countX=`echo $countX + 1| bc`

	countY=0
	dy=$startY
	while [ "$countY" -lt "10" ]
	do
		dy=`echo $dy + $stepY | bc`
		echo "$countY      ", $dy
		countY=`echo $countY + 1| bc`

		countZ=0
		dz=$startZ
		while [ "$countZ" -lt "10" ]
		do
			dz=`echo $dz + $stepZ | bc`
			countZ=`echo $countZ + 1| bc`

			echo "#test  $countX, $countY, $countZ      ", $dx, $dy, $dz | tee -a alignOut.txt

			~/bin/translateMaplet $model.MAP $dx $dy $dz | tee -a alignOut.txt
			$exPath/Maplet2FITS tr-$model.MAP f
			$exPath/FITS2OBJ --local f tr-$model.obj
			$exPath/CompareOBJ tr-$model.obj ~/truthTAG1-5cm-1.1K.obj | tee -a alignOut.txt

		done		# Z


	done		# Y


done		# X

grep -e test -e Root alignOut.txt | tee alignEval.txt
