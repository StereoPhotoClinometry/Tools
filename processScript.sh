# Takes a list of image names and runs process_fits on them
# Eric E. Palmer, 9 June 2015

file=$1

#prefix="imgAp"		# use for Approach
#prefix="imgPSM"		# use for Preliminary Survey, Map
#prefix="imgPSP"		# use for Preliminary Survey, Poly
prefix="imgDSP"		# use for Det Survey, Poly
#prefix="imgDSM"		# use for Det Survey, Map
prefix="imgMap"		# use for Det Survey, Poly

list=`cat $file`

for item in $list 
do
	echo "$prefix/$item" | process_fits
done
