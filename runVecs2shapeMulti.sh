#!/bin/bash

# This script runs vecs2shape on an ICQ shape model for 
# many spherical harmonic solution values of l: 
# The required arguments are the input vectorfile (ICQ), 
# the q-size of the output shapefile
# the min l value you want to compute,
# the max l value you want to compute,  
# the base file name for the output shapefile (ICQ),
# the q-size of the dumber shapefile you want to produce
# y or no for trimming the albedo

# the program automatically puts the output files into the vecs2shape directory


# Carolyn Ernst 08/25/2021

# example:
# ./runVecs2shapeMulti.sh newVecs.txt 512 3 21 SHAPEL_final_vecs2shape

#defining directory here, to provide easier transitions to defining this as an input in the future
directory='vecs2shape'

vectorsname=$1
qsize=$2
lmin=$3
lmax=$4
outfilebasename=$5
#dumbervalue=$6
#albedo=$7

#dumbqsize=$[${qsize}/${dumbervalue}]


if [ -d ${directory} ]
then
    echo "Directory ${directory} exists."
else
    echo "Error: Directory ${directory} does not exists - creating it now."
    mkdir ${directory}
fi


lvalue=${lmin}
echo "~~~~~Running vecs2shape for l="${lmin}"to l="${lmax}"~~~~~"

while [ $lvalue -le ${lmax} ]
do
	echo ""
	echo ">>>>>>Running l="$lvalue
	# make the vecs2shape input file
		echo "${vectorsname}" >vecs2shape/vecs2shape.tmp
		echo "${qsize} ${lvalue}" >>vecs2shape/vecs2shape.tmp
		echo "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".TXT" >>${directory}/vecs2shape.tmp
	
	vecs2shape <${directory}/vecs2shape.tmp
	
#	ICQ2PLT "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".TXT" "vecs2shape/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".PLT"
#	PLT2OBJ "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".PLT" "vecs2shape/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".obj"
#	rm "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".PLT"
	ShapeFormatConverter -input "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".TXT" -inputFormat icq -output "vecs2shape/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".obj"	
# Originally had the dumber step in here, but now have it as its own bulk dumber step. 
# Retaining this for now just in case, but commented out.
#	# make the dumber input file
#		echo "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}".TXT" >${directory}/vecs2shapedumber.tmp
#		echo "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".TXT" >>${directory}/vecs2shapedumber.tmp
#		echo "${dumbervalue}" >>${directory}/vecs2shapedumber.tmp
#		echo "${albedo}" >>${directory}/vecs2shapedumber.tmp
#	
#	dumber <${directory}/vecs2shapedumber.tmp
#
#	ICQ2PLT "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".TXT" "vecs2shape/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".PLT"
#	PLT2OBJ "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".PLT" "vecs2shape/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".obj"
#   rm "${directory}/"${outfilebasename}"_vecs2shape_q"${qsize}"_l"${lvalue}"_D2q"${dumbqsize}".PLT"
#   
	lvalue=$[$lvalue+2]
done
