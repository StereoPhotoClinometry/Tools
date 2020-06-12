# Eric E. Palmer - 11 Jan 2019
# Takes an argument of base boulder ID and 
#		runs things to prep for boulder fill

id=$1
root=${id}A
vers=$2


if [ "$1" == "" ] 
then
	echo "######## No argument given"
	echo "usage: $0 <id>"
	exit
fi

file=lsupport/$root.IN

if [ ! -e $file ] 
then
	echo "######## Bigmap config file $file cannot be found"
	exit
fi


dest=~/send/$id-$vers

mkdir -p $dest
echo $dest

echo "Bigmapping $file for $root"
bigMapRef < $file > tmp
echo $root | showmap
convert $root.pgm   $dest/$root.jpg

echo -n Number of maplets:
wc -l INSIDE.TXT

list=`cat INSIDE.TXT`

echo "Lithos'ing"
for item in $list
do
	echo $item

	if [ "$item" == "END" ]
	then
		continue;
	fi

	echo "i" > tmpRun
	echo "$item" >> tmpRun
	echo "n" >> tmpRun
	echo "n" >> tmpRun
	echo "m" >> tmpRun
	echo "q" >> tmpRun

	LITHOS < tmpRun > tmp
	grep Lat tmp > $dest/t-$item.txt 
	grep SCALE tmp >> $dest/t-$item.txt
	convert LMRK_DISPLAY1.pgm $dest/$item.jpg

done

echo "Copy inside"

grep -e Lat -e SCALE $dest/t-*.txt > /$dest/radius.txt


cp INSIDE.TXT $dest
cat INSIDE.TXT >> newList.txt

tail -5 SIGMAS.TXT | tee -a notes
cp SIGMAS.* $dest

makeOBJ.sh $root
echo y | mv $root.obj $dest


