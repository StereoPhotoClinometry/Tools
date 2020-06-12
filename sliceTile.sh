# Eric E. Palmer - 4 June 2019
# Looks at file and breaks out lat/lon/ZNMAP that was used in tiling

# Hack
# Assuming using John's tileZMAPS.sh script
#		(where you have several tile[1234] directories and a steptileZ**** in each)
#	Run
#		ls step*/*OOT > bigList
#		sliceTile.sh bigList
#
#	Use "grep del evalOut" to see what needs to be fixed

file=$1

if [ "$file" = "" ]
then
	echo "Error, no file selected.  File should be a list, with path, of OOT files to parse"
	exit
fi

list=`cat $file`

echo "# $file" > evalOut
d=`date`
echo "# $d" >> evalOut
Echo "# ZMAP  Lat   Lon Del" >> evalOut

for item in $list
do
	#echo $item
	map=`echo $item | cut -c 9-14 `

	del=`grep -m 1 delete $item`

	lat=`grep -m 1 "Lat" $item  | cut -c 18-25` 
	lon=`grep -m 1 "Lat" $item  | cut -c 28-36` 


	echo $map $lat $lon $del| tee -a evalOut	


done
