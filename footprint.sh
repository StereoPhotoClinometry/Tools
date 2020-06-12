# 6 Mar 2016 - Eric E. Palmer
# Takes a list of pictures and calculates their corners

file=$1

if [ "$file" == "" ]
then
	echo "usage: $0 <file>"
	exit
fi

echo "# $0 `date`" > footprint.txt
echo "# Start: `head -1 $file`" >> footprint.txt
echo "# End: `tail -1 $file`" >> footprint.txt

list=`grep -v \# $file | cut -c 1-13`

echo > tmpOut.txt 
for item in $list
do

	echo $item
	echo "f" > tmpRun.txt
	echo "p" >> tmpRun.txt
	echo "$item" >> tmpRun.txt
	echo "1 1" >> tmpRun.txt

	echo "f" >> tmpRun.txt
	echo "p" >> tmpRun.txt
	echo "$item" >> tmpRun.txt
	echo "1 1024" >> tmpRun.txt

	echo "f" >> tmpRun.txt
	echo "p" >> tmpRun.txt
	echo "$item" >> tmpRun.txt
	echo "1024 1024" >> tmpRun.txt

	echo "f" >> tmpRun.txt
	echo "p" >> tmpRun.txt
	echo "$item" >> tmpRun.txt
	echo "1024 1" >> tmpRun.txt
	echo "q" >> tmpRun.txt

	lithos < tmpRun.txt | grep Lat | cut -c 15- >> tmpOut.txt
	echo >> tmpOut.txt

done

awk -f /opt/local/spc/bin/footprint.awk tmpOut.txt > footprint.txt
