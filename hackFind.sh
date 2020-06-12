# Eric E. Palmer - 18 Dec 2019
# 	Run lithos until the albedo stdev is greater than 0.1

map=$1

runUntil=$2

if [ "$map" == "" ];
then
	echo "Usage: $0 <map>"
	exit
fi

echo "# $map" | tee  tmpResults

echo i > tmpRun
echo $map >> tmpRun
echo n >> tmpRun
echo n >> tmpRun

echo 0 >> tmpRun
echo 0 >> tmpRun
echo 40 >> tmpRun

echo 2 >> tmpRun
echo 8  >> tmpRun
echo 7 >> tmpRun
echo .01 >> tmpRun
echo 1 >> tmpRun
echo 6 >> tmpRun
echo y >> tmpRun
echo y >> tmpRun
echo 2 >> tmpRun
echo .01 >> tmpRun
echo 0  >> tmpRun
echo .025 >> tmpRun
echo 15 >> tmpRun
echo 0 >> tmpRun
echo u >> tmpRun
echo 1 >> tmpRun
echo q >> tmpRun


if [ "$runUntil" == "" ];
then
	runUntil=100
fi


cnt=0
pass=1
max=0
while [ -e MAPFILES/$map.MAP ]
do
	cnt=`echo $cnt + 1 | bc`

	if [ "$cnt" == "$runUntil" ]
	then
		echo "Escape:  I've reached $cnt"
		finished $map-best-$max
		exit
	fi


	lithos < tmpRun > tmpOut
	line=`echo $map | flatAlbedo | tail -1 `

	#echo "     $line"
	score=`echo $line  | awk '{ print $3  }'`

##### Testing at to see if it the max
	if [ "$pass" == 1 ]
	then
		#echo $line  | awk -v max=$max '{ if ($3 > max) {print "new-max", max} else {print "same"} }'
		ans=`echo $line  | awk -v max=$max '{ if ($3 > max) {print 1} else {print 0} }'`
	fi


	if [ "$ans" == "1" ]
	then
		echo "Found update $score (max was $max) after $cnt"
		/bin/cp -f MAPFILES/$map.MAP hold-$map.MAP
		/bin/cp -f LMKFILES/$map.LMK hold-$map.LMK
		max=$score
	fi

	echo "    Score: $score     Max: $max  ($cnt)" | tee -a tmpResults

done

