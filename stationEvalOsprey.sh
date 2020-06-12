#!/bin/bash
# Script to get list of images in landmarks.
# John R. Weirich Oct 31 2019
# ...................................
# Updated to work for all BBD stations
# Updated to work for Rec A, though it doesn't distinguish stations
# Renamed and made more "official"
# 05 Feb 2020: Updated values for Rec A to distinguish stations
# 06 Feb 2020: Updated values for Rec B to distinguish stations
# 11 Mar 2020: Added Osprey RecA and RecB. Since the output is getting long, this only works for Osprey
# 04 Jun 2020: Added Rec C Osprey and distinguishes the two stations.
file=$1

echo "If you haven't run RESIDUALS since tiling, the formatting may be off."
mkdir -p eval

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

OspreyA1a="P6241872"
OspreyA1b="P6241873"
OspreyA1c="P6241874"
OspreyA1d="P6241875"
OspreyA1e="P6241876"
OspreyA1f="P6241877"
OspreyA1g="P6241878"
OspreyA1h="P6241879"
OspreyA1i="P6241880"
OspreyA1j="P6241881"
OspreyA1k="P6241882"

OspreyA2a="P6241884"
OspreyA2b="P6241885"
OspreyA2c="P6241886"
OspreyA2d="P6241887"
OspreyA2e="P6241888"
OspreyA2f="P6241889"
OspreyA2g="P6241890"

OspreyA3a="P6241891"
OspreyA3b="P6241892"
OspreyA3c="P6241893"
OspreyA3d="P6241894"
OspreyA3e="P6241895"
OspreyA3f="P6241896"
OspreyA3g="P6241897"
OspreyA3h="P6241898"
OspreyA3i="P6241899"
OspreyA3j="P6241900"
OspreyA3k="P6241901"

OspreyA4a="P6241905"
OspreyA4b="P6241906"
OspreyA4c="P6241907"
OspreyA4d="P6241908"
OspreyA4e="P6241909"
OspreyA4f="P6241910"
OspreyA4g="P6241911"
OspreyA4h="P6241912"
OspreyA4i="P6241913"
OspreyA4j="P6241914"
OspreyA4k="P6241915"
OspreyA4l="P6241916"
OspreyA4m="P6241917"

OspreyB1a="P634730"
OspreyB1b="P634731"
OspreyB1c="P6347320"
OspreyB1d="P6347321"

OspreyB2a="P6347323"
OspreyB2b="P6347324"
OspreyB2c="P6347325"
OspreyB2d="P6347326"
OspreyB2e="P6347327"
OspreyB2f="P6347328"
OspreyB2g="P6347329"
OspreyB2h="P634733"
OspreyB2i="P634734"
OspreyB2j="P634735"

OspreyC1a="P643802"
OspreyC1b="P643803"
OspreyC1c="P643804"
OspreyC1d="P643805"
OspreyC1e="P6438060"

OspreyC2a="P6438063"
OspreyC2b="P6438064"
OspreyC2c="P6438065"
OspreyC2d="P6438066"
OspreyC2e="P6438067"
OspreyC2f="P6438068"
OspreyC2g="P6438069"
OspreyC2h="P643807"
OspreyC2i="P643808"


list=`cat $1`


#echo "#NAME      RES           LAT        WLON           $img1       $img2" > eval/evalStation.txt
echo "#Name 	  RES		Lat        wLon	           FB0        FB1        FB2        FB3       FB4      FB5a       FB5b       FB6a       FB6b      FB7      PStations OA1 OA2 OA3 OA4 OB1 OB2 OC1 OC2" > eval/evalStation.txt 

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

 OA1a=`grep $OspreyA1a LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1b=`grep $OspreyA1b LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1c=`grep $OspreyA1c LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1d=`grep $OspreyA1d LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1e=`grep $OspreyA1e LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1f=`grep $OspreyA1f LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1g=`grep $OspreyA1g LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1h=`grep $OspreyA1h LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1i=`grep $OspreyA1i LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1j=`grep $OspreyA1j LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1k=`grep $OspreyA1k LMKFILES/$item.LMK | wc | cut -c1-10`
 OA1=`echo "$OA1a + $OA1b + $OA1c + $OA1d + $OA1e + $OA1f + $OA1g + $OA1h + $OA1i + $OA1j + $OA1k" | bc`

 OA2a=`grep $OspreyA2a LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2b=`grep $OspreyA2b LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2c=`grep $OspreyA2c LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2d=`grep $OspreyA2d LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2e=`grep $OspreyA2e LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2f=`grep $OspreyA2f LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2g=`grep $OspreyA2g LMKFILES/$item.LMK | wc | cut -c1-10`
 OA2=`echo "$OA2a + $OA2b + $OA2c + $OA2d + $OA2e + $OA2f + $OA2g" | bc`

 OA3a=`grep $OspreyA3a LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3b=`grep $OspreyA3b LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3c=`grep $OspreyA3c LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3d=`grep $OspreyA3d LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3e=`grep $OspreyA3e LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3f=`grep $OspreyA3f LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3g=`grep $OspreyA3g LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3h=`grep $OspreyA3h LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3i=`grep $OspreyA3i LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3j=`grep $OspreyA3j LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3k=`grep $OspreyA3k LMKFILES/$item.LMK | wc | cut -c1-10`
 OA3=`echo "$OA3a + $OA3b + $OA3c + $OA3d + $OA3e + $OA3f + $OA3g + $OA3h + $OA3i + $OA3j + $OA3k" | bc`

 OA4a=`grep $OspreyA4a LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4b=`grep $OspreyA4b LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4c=`grep $OspreyA4c LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4d=`grep $OspreyA4d LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4e=`grep $OspreyA4e LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4f=`grep $OspreyA4f LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4g=`grep $OspreyA4g LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4h=`grep $OspreyA4h LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4i=`grep $OspreyA4i LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4j=`grep $OspreyA4j LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4k=`grep $OspreyA4k LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4l=`grep $OspreyA4l LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4m=`grep $OspreyA4m LMKFILES/$item.LMK | wc | cut -c1-10`
 OA4=`echo "$OA4a + $OA4b + $OA4c + $OA4d + $OA4e + $OA4f + $OA4g + $OA4h + $OA4i + $OA4j + $OA4k + $OA4l + $OA4m" | bc`

 OB1a=`grep $OspreyB1a LMKFILES/$item.LMK | wc | cut -c1-10`
 OB1b=`grep $OspreyB1b LMKFILES/$item.LMK | wc | cut -c1-10`
 OB1c=`grep $OspreyB1c LMKFILES/$item.LMK | wc | cut -c1-10`
 OB1d=`grep $OspreyB1d LMKFILES/$item.LMK | wc | cut -c1-10`
 OB1=`echo "$OB1a + $OB1b + $OB1c + $OB1d" | bc`

 OB2a=`grep $OspreyB2a LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2b=`grep $OspreyB2b LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2c=`grep $OspreyB2c LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2d=`grep $OspreyB2d LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2e=`grep $OspreyB2e LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2f=`grep $OspreyB2f LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2g=`grep $OspreyB2g LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2h=`grep $OspreyB2h LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2i=`grep $OspreyB2i LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2j=`grep $OspreyB2j LMKFILES/$item.LMK | wc | cut -c1-10`
 OB2=`echo "$OB2a + $OB2b + $OB2c + $OB2d + $OB2e + $OB2f + $OB2g + $OB2h + $OB2i + $OB2j" | bc`

 OC1a=`grep $OspreyC1a LMKFILES/$item.LMK | wc | cut -c1-10`
 OC1b=`grep $OspreyC1b LMKFILES/$item.LMK | wc | cut -c1-10`
 OC1c=`grep $OspreyC1c LMKFILES/$item.LMK | wc | cut -c1-10`
 OC1d=`grep $OspreyC1d LMKFILES/$item.LMK | wc | cut -c1-10`
 OC1e=`grep $OspreyC1e LMKFILES/$item.LMK | wc | cut -c1-10`
 OC1=`echo "$OC1a + $OC1b + $OC1c + $OC1d + $OC1e" | bc`

 OC2a=`grep $OspreyC2a LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2b=`grep $OspreyC2b LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2c=`grep $OspreyC2c LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2d=`grep $OspreyC2d LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2e=`grep $OspreyC2e LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2f=`grep $OspreyC2f LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2g=`grep $OspreyC2g LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2h=`grep $OspreyC2h LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2i=`grep $OspreyC2i LMKFILES/$item.LMK | wc | cut -c1-10`
 OC2=`echo "$OC2a + $OC2b + $OC2c + $OC2d + $OC2e + $OC2f + $OC2g + $OC2h + $OC2i" | bc`

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
 echo "$info $FB0 $FB1 $FB2 $FB3       $FB4 $FB5a $FB5b $FB6a $FB6b       $FB7        $Stat         $OA1   $OA2   $OA3   $OA4   $OB1   $OB2   $OC1   $OC2" >> eval/evalStation.txt

done
