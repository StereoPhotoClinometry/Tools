#!/bin/bash
# Script to get list of images in landmarks.
# John R. Weirich Oct 31 2019
# ...................................
# Updated to work for all BBD stations
# Updated to work for Rec A, though it doesn't distinguish stations
# Renamed and made more "official"
# 05 Feb 2020: Updated values for Rec A to distinguish stations
# 06 Feb 2020: Updated values for Rec B to distinguish stations
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

NightA1a="P625395"
NightA1b="P6253960"

NightA2a="P6253961"
NightA2b="P6253962"
NightA2c="P6253963"
NightA2d="P6253964"
NightA2e="P6253965"
NightA2f="P6253966"
NightA2g="P6253967"
NightA2h="P6253968"

NightA3a="P6253971"
NightA3b="P6253972"
NightA3c="P6253973"
NightA3d="P6253974"
NightA3e="P6253975"
NightA3f="P6253976"
NightA3g="P6253977"
NightA3h="P6253978"
NightA3i="P6253979"
NightA3j="P6253980"
NightA3k="P6253981"
NightA3l="P6253982"

NightA4a="P6253983"
NightA4b="P6253984"
NightA4c="P6253985"
NightA4d="P6253986"
NightA4e="P6253987"
NightA4f="P6253988"
NightA4g="P6253989"
NightA4h="P625399"

NightB1a="P632923"
NightB1b="P632924"
NightB1c="P6329250"
NightB1d="P6329251"
NightB1e="P6329252"
NightB1f="P6329253"
NightB1g="P6329254"
NightB1h="P6329255"

NightB2a="P6329258"
NightB2b="P6329259"
NightB2c="P632926"
NightB2d="P632927"




list=`cat $1`


#echo "#NAME      RES           LAT        WLON           $img1       $img2" > eval/evalStation.txt
echo "#Name 	  RES		Lat        wLon	           FB0        FB1        FB2        FB3       FB4      FB5a       FB5b       FB6a       FB6b      FB7      PStations NA1 NA2 NA3 NA4 NB1 NB2" > eval/evalStation.txt 

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

 NA1a=`grep $NightA1a LMKFILES/$item.LMK | wc | cut -c1-10`
 NA1b=`grep $NightA1b LMKFILES/$item.LMK | wc | cut -c1-10`
 NA1=`echo "$NA1a + $NA1b" | bc`

 NA2a=`grep $NightA2a LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2b=`grep $NightA2b LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2c=`grep $NightA2c LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2d=`grep $NightA2d LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2e=`grep $NightA2e LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2f=`grep $NightA2f LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2g=`grep $NightA2g LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2h=`grep $NightA2h LMKFILES/$item.LMK | wc | cut -c1-10`
 NA2=`echo "$NA2a + $NA2b + $NA2c + $NA2d + $NA2e + $NA2f + $NA2g + $NA2h" | bc`

 NA3a=`grep $NightA3a LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3b=`grep $NightA3b LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3c=`grep $NightA3c LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3d=`grep $NightA3d LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3e=`grep $NightA3e LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3f=`grep $NightA3f LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3g=`grep $NightA3g LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3h=`grep $NightA3h LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3i=`grep $NightA3i LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3j=`grep $NightA3j LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3k=`grep $NightA3k LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3l=`grep $NightA3l LMKFILES/$item.LMK | wc | cut -c1-10`
 NA3=`echo "$NA3a + $NA3b + $NA3c + $NA3d + $NA3e + $NA3f + $NA3g + $NA3h + $NA3i + $NA3j + $NA3k + $NA3l" | bc`

 NA4a=`grep $NightA4a LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4b=`grep $NightA4b LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4c=`grep $NightA4c LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4d=`grep $NightA4d LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4e=`grep $NightA4e LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4f=`grep $NightA4f LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4g=`grep $NightA4g LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4h=`grep $NightA4h LMKFILES/$item.LMK | wc | cut -c1-10`
 NA4=`echo "$NA4a + $NA4b + $NA4c + $NA4d + $NA4e + $NA4f + $NA4g + $NA4h" | bc`

 NB1a=`grep $NightB1a LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1b=`grep $NightB1b LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1c=`grep $NightB1c LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1d=`grep $NightB1d LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1e=`grep $NightB1e LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1f=`grep $NightB1f LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1g=`grep $NightB1g LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1h=`grep $NightB1h LMKFILES/$item.LMK | wc | cut -c1-10`
 NB1=`echo "$NB1a + $NB1b + $NB1c + $NB1d + $NB1e + $NB1f + $NB1g + $NB1h" | bc`

 NB2a=`grep $NightB2a LMKFILES/$item.LMK | wc | cut -c1-10`
 NB2b=`grep $NightB2b LMKFILES/$item.LMK | wc | cut -c1-10`
 NB2c=`grep $NightB2c LMKFILES/$item.LMK | wc | cut -c1-10`
 NB2d=`grep $NightB2d LMKFILES/$item.LMK | wc | cut -c1-10`
 NB2=`echo "$NB2a + $NB2b + $NB2c + $NB2d" | bc`


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
 echo "$info $FB0 $FB1 $FB2 $FB3       $FB4 $FB5a $FB5b $FB6a $FB6b       $FB7        $Stat         $NA1   $NA2   $NA3   $NA4   $NB1   $NB2" >> eval/evalStation.txt

done
