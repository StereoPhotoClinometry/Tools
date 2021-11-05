# Eric E. Palmer -- 21 April 2016
# Make a list of the 80% best landmarks
# This will use temporary files in your home directory
# Updated 11 Jan 2018 to deal wtih v3.0.3
# Updated 05 Nov 2021 to grep on searchStr instead of level, was grabbing wrong pattern

level=$1

if [ "$level" == "" ] 
then
	echo "nothing"
else
	echo "Level $level [m]"
	searchStr='Res:'$level
	echo "searchStr >>>>$searchStr<<<<"
fi

p=`pwd`
#exPath=/Volumes/Data1/spc-test/shape4/support
exPath=/opt/local/spc/bin

awk -f $exPath/calResiduals.awk RESIDUALS.TXT | grep -v -e Average -e Name > ~/tmp80a

cd ~
if [ "$level" != "" ] 
then
	grep $searchStr tmp80a > tmp80aa
	#grep Res:0.0003 tmp80a > tmp80aa
	#grep $searchStr tmp80a > tmp80aa
else
	echo "Skipping"
	/bin/mv -f tmp80a tmp80aa
fi

sort -n -k5 tmp80aa > tmp80b
num=`wc -l tmp80b | cut -c 1-8`
echo "Num Landmarks: $num"
only80=`echo "$num * 4 / 5 " | bc`
echo "80%: $only80"
cut -c 5-10 tmp80b | head -$only80 > tmp80c
sed -e "s/$/.LMK/" tmp80c > tmp80d

cd $p/LMKFILES

grep VLM `cat ~/tmp80d` > ~/tmpPts
sed -e "s/D/E/g" ~/tmpPts | cut -c 12-72 > ~/finalCloud.txt
echo "~/finalCloud.txt is the finalCloud.txt"
echo "Residual at 80:  `head -$only80 ~/tmp80b | tail -1`"
#echo "Residual at 80:  `tail -1 ~/tmp80b`"

