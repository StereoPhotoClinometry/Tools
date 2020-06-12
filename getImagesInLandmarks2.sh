#!/bin/bash
# Script to get list of images in landmarks.
# John R. Weirich Apr 02 2019
# ...................................
# Updated to work for all BBD stations


file=$1

img1="M608"
img2="M609"

psNin1="M5971"
psNin2="M5972"
psNout1="M59721"
psNin2="M5972"

psE="M5978"
psS="M5979"

ds0="M604"
ds1="P6052"
ds2="M6058"
ds3="P6064"
ds4a="P6070"
ds4b="P6071"

ds5a="P6076"
ds5b="P6077"

ds6a="P6082"
ds6b="P6083"

ds7a="M608"
ds7b="M609"

rA="P62"

list=`cat $1`


#echo "#NAME      RES           LAT        WLON           $img1       $img2" > tmpjrw
echo "#Name 	  RES		Lat        wLon	           FB0        FB1        FB2        FB3       FB4      FB5a       FB5b       FB6a       FB6b      FB7      PStations rA" > tmpjrw

for item in $list
do
	if [ "$item" == "END" ]
	then
		break;
	fi
 FB0=`grep $ds0 LMKFILES/$item.LMK | wc | cut -c1-10`
 FB1=`grep $ds1 LMKFILES/$item.LMK | wc | cut -c1-10`
 FB2=`grep $ds2 LMKFILES/$item.LMK | wc | cut -c1-10`
 FB3=`grep $ds3 LMKFILES/$item.LMK | wc | cut -c1-10`
 FB4a=`grep $ds4a LMKFILES/$item.LMK | wc | cut -c1-10`
 FB4b=`grep $ds4b LMKFILES/$item.LMK | wc | cut -c1-10`
 FB4=`echo "$FB4a + $FB4b" | bc`
 FB5a=`grep $ds5a LMKFILES/$item.LMK | wc | cut -c1-10`
 FB5b=`grep $ds5b LMKFILES/$item.LMK | wc | cut -c1-10`
 FB5=`echo "$FB5a + $FB5b" | bc`
 FB6a=`grep $ds6a LMKFILES/$item.LMK | wc | cut -c1-10`
 FB6b=`grep $ds6b LMKFILES/$item.LMK | wc | cut -c1-10`
 FB6=`echo "$FB6a + $FB6b" | bc`
 FB7a=`grep $ds7a LMKFILES/$item.LMK | wc | cut -c1-10`
 FB7b=`grep $ds7b LMKFILES/$item.LMK | wc | cut -c1-10`
 FB7=`echo "$FB7a + $FB7b" | bc`

 recA=`grep $rA LMKFILES/$item.LMK | wc | cut -c1-10`

 Stat=0
 if [ "$FB1" -gt "0" ]
 then 
	Stat=`echo "$Stat + 1" | bc`
 fi

 if [ "$FB3" -gt "0" ]
 then
        Stat=`echo "$Stat + 1" | bc`
 fi

 if [ "$FB4" -gt "0" ]
 then
        Stat=`echo "$Stat + 1" | bc`
 fi

 if [ "$FB5" -gt "0" ]
 then
        Stat=`echo "$Stat + 1" | bc`
 fi

 if [ "$FB6" -gt "0" ]
 then
        Stat=`echo "$Stat + 1" | bc`
 fi


 info=`grep $item MAPINFO.TXT | cut -c1-43`
 echo "$info $FB0 $FB1 $FB2 $FB3       $FB4 $FB5a $FB5b $FB6a $FB6b       $FB7        $Stat  $recA" >> tmpjrw

done
