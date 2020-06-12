# 29 Oct 2014
#	Give it an image name, and it will compute the difference
#		between the original nominal and the sumfile

file=$1

cd SUMFILES
list=`ls *SUM`
cd ..
echo "# `date`" > tmpOut


for img in $list 
do
	short=`echo $img | cut -c 1-12`
	#echo $short

	# Does different location SUMFILES
	path1="/SPC_Test/Component/Bennu/SUMFILES"
	path2="/Volumes/Share/epalmer/back/2014-10-29/Component/Bennu/SUMFILES"
	path1="/SPC_Test/Component/Bennu/sum-pre"
	cat $path1/$short.SUM $path2/$short.SUM > tmpData.txt
	
	# Does local nominals vs SUMFILES
	#cat NOMINALS/$short.NOM SUMFILES/$short.SUM > tmpData.txt

	awk -f support/vectorDiff.awk -v name="$short" tmpData.txt | tee -a tmpOut
#exit
done

