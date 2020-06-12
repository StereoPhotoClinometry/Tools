file=$1
vers=$2
binPath=~/eval/bin/
truth=$binPath/TTAG1L-25m2.5cm.obj

echo "################## $file $vers #########" | tee -a single.log
date >> single.log

newFile="MAPFILES/$file.MAP"
echo $newFile
if [ -e $newFile ]; then
	echo working with $file | tee -a single.log
else
	echo "Missing $file"
	exit
fi

	line="$binPath/Maplet2FITS $newFile fit "
	echo $line  | tee -a single.log
	$line 

	line="$binPath/FITS2OBJ --local fit $file.obj"
	echo $line | tee -a single.log
	$line 

	line="$binPath/CompareOBJ --save-plate-diff vDelta1-$vers $file.obj $truth"
	echo $line  | tee -a single.log
	$line  | tee -a single.log

	$binPath/CompareOBJ  --compute-optimal-translation $file.obj $truth  | tee -a single.log
	$binPath/CompareOBJ  --compute-optimal-translation-and-rotation  $file.obj $truth  | tee -a single.log

