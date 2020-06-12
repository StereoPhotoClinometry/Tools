# 13 Dec 2015 -- Eric E. Palmer
# Script to batch run the register.  This is designed to be an improvement
#		over the standard make_scriptR program.
#		It includes saving images of problem images and
#		more diagonistics


# Test for a file.  Use one that is passed
if [ "$1" == "" ]; then
	file=make_script.in
else
	file=$1
fi

# Make sure the file exists
if [ ! -e $file ]; then
	echo File $file cannot be found
	exit
fi

# Set up output logs
time=`date`
mkdir -p runOut
date > runOut/log
num=`wc -l $file`
cnt=0

# Run through them all
list=`cat $file`

for item in $list 
do
	cnt=`echo $cnt + 1 | bc`
	echo "$item ($cnt of $num)"
	echo $item > tmpIn.txt
	cat look.seed >> tmpIn.txt
	#cat make_scriptR.seed >> tmpIn.txt
	register < tmpIn.txt > tmpOut.txt

	noCorr=`grep "No" tmpOut.txt`

	# See if it quite
	if [ "$noCorr" == "" ];
	then
		echo "Corr"
	else
		echo "No Correlation"
	fi

	# Measure displacement




	# Copy stuff for review
	convert TEMPFILE.ppm runOut/$item.jpg
	convert TEMPFILE.ppm ~/send/$item.jpg
	cp tmpOut.txt runOut/$item.log


done


