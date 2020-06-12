# POS_SCRIPT.sh
# By Kristofer Drozd with Massive help from Tanner Campbell
# Last updated November 20, 2015

# This script creates text files that are needed for LMRK_SUN_SC_POS.m code to run
# The user of this script must create a columb of landmark names to be analyzed with a text file 

rm -f LMRK_SUN_SC_POS_TXTFILES/LAT.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/LON.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/NUMBERPIC.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/PICTIMES.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/RESOLUTION.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SCOBJ1.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SCOBJ2.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SCOBJ3.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SZ1.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SZ2.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/SZ3.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/VLM1.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/VLM2.txt
rm -f LMRK_SUN_SC_POS_TXTFILES/VLM3.txt

list=`cat LMRK_SUN_SC_POS_TXTFILES/LMRKNAMES.txt`

for i in $list
do
grep $i MAPINFO.TXT | awk '{print $4}' >> LMRK_SUN_SC_POS_TXTFILES/LAT.txt
grep $i MAPINFO.TXT | awk '{print $5}' >> LMRK_SUN_SC_POS_TXTFILES/LON.txt
grep $i MAPINFO.TXT | awk '{print $7}' >> LMRK_SUN_SC_POS_TXTFILES/NUMBERPIC.txt
grep VLM LMKFILES/$i.LMK | awk '{print $1}' >> LMRK_SUN_SC_POS_TXTFILES/VLM1.txt
grep VLM LMKFILES/$i.LMK | awk '{print $2}' >> LMRK_SUN_SC_POS_TXTFILES/VLM2.txt
grep VLM LMKFILES/$i.LMK | awk '{print $3}' >> LMRK_SUN_SC_POS_TXTFILES/VLM3.txt
FUN=`awk '/PICTURES/{flag=1;next}/MAP/{flag=0}flag' LMKFILES/$i.LMK | cut -c -12`
	for j in $FUN
	do
	grep $j PICINFO.TXT | cut -c 17-40 >> LMRK_SUN_SC_POS_TXTFILES/PICTIMES.txt
	grep $j PICINFO.TXT | awk '{print $6}' >> LMRK_SUN_SC_POS_TXTFILES/RESOLUTION.txt
	grep SCOBJ SUMFILES/$j.SUM | awk '{print $1}' >> LMRK_SUN_SC_POS_TXTFILES/SCOBJ1.txt
	grep SCOBJ SUMFILES/$j.SUM | awk '{print $2}' >> LMRK_SUN_SC_POS_TXTFILES/SCOBJ2.txt
	grep SCOBJ SUMFILES/$j.SUM | awk '{print $3}' >> LMRK_SUN_SC_POS_TXTFILES/SCOBJ3.txt
	grep SZ SUMFILES/$j.SUM | awk '{print $1}' >> LMRK_SUN_SC_POS_TXTFILES/SZ1.txt
	grep SZ SUMFILES/$j.SUM | awk '{print $2}' >> LMRK_SUN_SC_POS_TXTFILES/SZ2.txt
	grep SZ SUMFILES/$j.SUM | awk '{print $3}' >> LMRK_SUN_SC_POS_TXTFILES/SZ3.txt
	done                                             
done

