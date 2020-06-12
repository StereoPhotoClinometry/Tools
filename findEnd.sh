# Eric E. Paalmer - 29 Oct 2019
# Searches through all the list and identifies
#  	all the files that are not complete.


list=`cat $1`
echo `date` > tmpOut

for item in $list
do
	ans=`tail -1 LMKFILES/$item.LMK | grep END`
	echo $item $ans >> tmpOut


done

grep -v END tmpOut | tmpResults
