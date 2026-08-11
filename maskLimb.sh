# Eric E. Palmer
# 		26 July 2022
# maskBlemish.sh -- this is a script to accept the output from the spc_tools 
#		program, limber.js
# version 1.1 -- added error checking

##################################################
# Global variables
# Change them to match your system
path="/usr/local/bin/spc/blessed/bin"
web="/Library/WebServer/Documents/data/"

read -p "Enter Image Number (12 char)> " img

##################################################
# Checks
# check that the image is there
if [ ! -e "IMAGEFILES/$img.DAT" ] 
then
	echo "$img does not exist in IMAGEFILES.  Exiting"
	exit 
fi

# Start basic script
echo $img > tmpRun	# This must come before BLEM test


##################################################
# See if we need to save or create a new blemish file
blem="BLEMISHES/$img.BLM"
if [ -e "$blem" ] 
then
	#echo "Blemish file exists"
	echo "n" >> tmpRun

	# Check to see if valid format.  If not, fail and warn
	ok=`tail -1 $blem`
	if [ ! "$ok" == "END" ]
	then
		echo "######################################"
		echo "##  Existing file ($blem) is corrupt"
		echo "######################################"
		echo "  Delete and start again"
		echo "  Note, do not <ctl>-C out of maskLimb.sh"
		exit
	fi


fi

##################################################
# Run BLEMISHES to get the output so you can see it
echo "q" >> tmpRun
echo "y" >> tmpRun
echo "n" >> tmpRun
$path/BLEMISHES < tmpRun > /dev/null
magick TEMPFILE.pgm $web/limber.jpg
echo "  $img image posted in $web/limber.jpg"


##################################################
# Loop over the whole system
while [ 1 ]
do
	echo "------------- Working on image $img -----------------------"
	echo  "  Samples (start & end) Lines (start & end) "
	echo  "  [Q-quit, D-display limbs, B-show BLEM], L-run LIMBER)  " 
	read -p "  >  " startX endX startY endY

	# Convert to upper
	ans=`echo $startX | tr lqdb LQDB`

##################################################
# Run blemishes to see the boxes
	if [ "$ans" == "B" ]
	then
		# Run BLEMISHES to get the output so you can see it
		echo "q" >> tmpRun
		echo "y" >> tmpRun
		echo "n" >> tmpRun
		echo "Re-rendering blemish image"
		$path/BLEMISHES < tmpRun > /dev/null
		magick TEMPFILE.pgm $web/limber.jpg
		echo "$img image posted in $web/limber.jpg"
		continue;
	fi


##################################################
# Run LIMBER internally
	if [ "$ans" == "L" ]
	then
		echo "  Running Limber"
		support/limber
		continue
	fi

##################################################
# Quit 
	if [ "$ans" == "Q" ]
	then
		echo "  Terminating"
		exit
	fi

##################################################
# Run Display with the limb points option on
	if [ "$ans" == "D" ]
	then
		echo "  Show limb points from [Display]"
		if [ ! -e LIMBFILES/$img.LIM ]
		then
			echo "### There is no LIMBFILE for image $img.  Run LIMBER"
			continue
		fi
		echo $img > tmpRun
		echo "n" >> tmpRun
		echo "y" >> tmpRun
		echo "n" >> tmpRun
		echo "n" >> tmpRun
		echo "n" >> tmpRun
		echo "n" >> tmpRun
		Display < tmpRun
		magick TEMPFILE.pgm $web/limber.jpg
		continue;
	fi

##################################################
# If you get here, then try to do points
##################################################


##################################################
# Validate input
line="$startX $endX $startY $endY"
bad=`echo $line | grep "[a-zA-Z]" `
if [ "$bad" != "" ]
then
	echo "### Invalid input:  $bad"
	continue;
fi

# Check num of parameters
cnt=`echo $line | wc -w`
if [ $cnt -lt 4 ]
then
	echo "### Too few arguments"
	continue;
fi



# Flip if end in lower than start
	if [ "$endX" -lt "$startX" ]
	then
		echo "  Samples [X] start higher than end, flipping"
		hold=$startX
		startX=$endX
		endX=$hold
	fi

	if [ "$endY" -lt "$startY" ]
	then
		echo "  Lines [Y] start higher than end, flipping"
		hold=$startY
		startY=$endY
		endY=$hold
	fi

##################################################
# Push the mask into the blemishes file
	echo $img > tmpRun
	echo "n" >> tmpRun
	echo "b" >> tmpRun
	echo $startX $endX $startY $endY >> tmpRun
	echo "q" >> tmpRun
	echo "y" >> tmpRun
	echo "n" >> tmpRun
	/usr/local/bin/spc/blessed/bin/BLEMISHES < tmpRun > /dev/null
	magick TEMPFILE.pgm $web/limber.jpg
	echo "  Updated"
	echo

done
