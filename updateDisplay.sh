#!/bin/bash
# Eric E. Palmer, Updated Feb 7th, 2016
# This waits a few seconds and updates the SPC output files
# This will shutdown after a week
# version 1.0

time=`echo 60*60*60*12 | bc`		# 12 hours
time=86400							# week
time=345600							# month


# Define the subdirectory.  
#If given, it will use a subdirectory in data
sub=$1
if [ "$sub" == "" ];
then
	running=`ps ax | grep $0 | grep -v grep | wc -l`
	num=`echo $running - 2 | bc`

	# I can't tell if someone is using data/
	# Just give a warning
	if [ "$num" -gt "0" ];
	then
		echo "################################"
		echo "##### Running in data/ directory"
		echo "There are $num other users of $0.  You may have a conflict"
		ps ax | grep $0 | grep -v grep 
		echo "################################"
		running=0
	fi
else
	running=`ps ax | grep $0 | grep -v grep | grep $sub | wc -l`
	sub="$sub/";
fi

# Log the current start time, in seconds
start=`date +%s`

# Check to see if currently running in that directory

#echo "### $running"
if [ "$running" -gt "2" ];
then
	echo "We have a version of $0 $1 already running"
	ps ax | grep $0 | grep -v grep  
	exit
fi


# Test to see if you are running on a Mac Server, or a normal mac.
path="/Library/Server/Web/Data/Sites/Default/data/$sub"
if [ -e $path ];
then
	path="/Library/Server/Web/Data/Sites/Default/data/$sub"
	echo "  Machine:  Server "
else
	path="/Library/WebServer/Documents/data/$sub"
	echo "  Machine:  Local "
fi

# Test to see if the final path exists, error if it doesn't
if [ ! -e $path ];
then
	echo $path does not exit
	exit
fi
valid=0;

echo "Using $path"
# Loop forever
while [ 1 ]
do
	# Create a secondary file and move it rather than destorying/overwrite
	# This allows a longer web-download
	if [ -e LMRK_DISPLAY1.pgm ];
	then
		valid=1
		convert LMRK_DISPLAY1.pgm landmarks.jpg
		/bin/mv -f $path/landmarks.jpg $path/old-landmarks.jpg
		/bin/mv -f landmarks.jpg $path/landmarks.jpg
	fi

	# Create a secondary file and move it rather than destorying/overwrite
	# This allows a longer web-download
	if [ -e LMRK_DISPLAY1.pgm ];
	then
		valid=1
		convert LMRK_DISPLAY1.pgm autoregister.jpg
		/bin/mv -f $path/autoregister.jpg $path/old-autoregister.jpg
		/bin/mv -f autoregister.jpg $path/autoregister.jpg
	fi

	if [ -e TEMPFILE.pgm ];
	then
		valid=1
		convert TEMPFILE.pgm register.jpg
		/bin/mv -f $path/register.jpg $path/old-register.jpg
		/bin/mv -f register.jpg $path/register.jpg
		# Not worrying about this
	fi
	if [ -e TEMPFILE.ppm ];
	then
		valid=1
		convert TEMPFILE.ppm $path/registerC.jpg
	fi


	# Push any file named 1.jpg to be displayed on the server
	if [ -e 1.jpg ];
	then
		valid=1
		cp 1.jpg $path/1.jpg
	fi

	# Push any file named TEMPFILE.jpg to be displayed on the server
	if [ -e TEMPFILE.pgm ];
	then
		valid=1
		convert TEMPFILE.pgm $path/2.jpg
	fi
	
	# How long to wait between pushes 
	sleep 3

	# Compute how long this has been running
	current=`date +%s`
	delta=`echo $current - $start | bc`
	#echo $start, $current, $delta

	# quit if it has been running for a long time (week/month)
	if [ "$delta" -gt "$time" ];
	then
		echo "You've run out of time"
		exit;
	fi

	# If we run through the loop and find no files to process, quit
	if [ "$valid" -eq "0" ];
	then
		echo "No valid files -- processing stopping"
		break;
	fi



done

