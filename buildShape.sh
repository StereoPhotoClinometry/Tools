# 3 Nov 2014
# 	This builds the shape using standard techniques
#	Updated so that it doesn't equire starting shape model is 512

if [ "$1" == "" ]
then
   echo "Usage: $0 <suffix>"
   exit
fi

myPath="/opt/local/spc/bin/"
suffix=$1
prev=dumb-$suffix

vers="1.2"

date > shape.log

Q=`head -1 SHAPEFILES/SHAPE.TXT | awk '// {print $1}' `
head -1 SHAPEFILES/SHAPE.TXT | awk '// {print $1}' 
echo "Starting Q: $Q"  | tee -a shape.log
echo "Version $vers"  | tee -a shape.log


if [ "$Q" == "512" ] 
then
	dummyQ=16
fi
if [ "$Q" == "256" ] 
then
	dummyQ=8
fi
if [ "$Q" == "128" ] 
then
	dummyQ=4
fi
if [ "$Q" == "64" ] 
then
	dummyQ=2
fi

# Skip 32, run dummer for everything else
if [ "$Q" == "32" ] 
then
	cp SHAPEFILES/SHAPE.TXT SHAPEFILES/dumb$suffix
	echo "Skipping dumber" | tee -a shape.log
else
	echo "SHAPEFILES/SHAPE.TXT" > tmpRun.txt
	echo "SHAPEFILES/$prev" >> tmpRun.txt
	echo $dummyQ >> tmpRun.txt
	echo "y" >> tmpRun.txt
	cat tmpRun.txt >> shape.log

	dumber < tmpRun.txt  | tee -a shape.log		# normally used
fi



list="64 128 256 512"

for i in $list 
do
	current=shape-$suffix-$i
	echo "Working on $i"
	echo "SHAPEFILES/$prev" > tmpRun.txt
	echo "2 100 1.67773" >> tmpRun.txt
	echo "SHAPEFILES/$current" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo ".15" >> tmpRun.txt
	echo ".025" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "1" >> tmpRun.txt
	echo "0" >> tmpRun.txt
	cat tmpRun.txt >> shape.log
	#densify < tmpRun.txt | tee -a shape.log
	densifya < tmpRun.txt | tee -a shape.log
	#bin/bin/densify_Hav < tmpRun.txt | tee -a shape.log
	prev=$current

	if [ $i == "128" ]; then
		densify < tmpRun.txt | tee -a shape.log
		echo "Got 128"
		echo "y" | cp SHAPEFILES/SIGMA.TXT sigma-$suffix-$i
	fi

done
echo SHAPEFILES/$current | shape2maps
$myPath/viewShape.sh


