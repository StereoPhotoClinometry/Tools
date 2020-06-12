# Eric E. Palmer - 19 Nov 2018
# This is a script that monitor can run when it finishes
#    an iteration.  It requires the daemon to be running
#    and localLoop flag to be on.

############################
id=$1
#finished Iteration-$id
echo "Ended iteration: $id at `date`" >> notes
p=`pwd`

############################
# Extra notification
############################
w=whoami
#if [ "$w" == "epalmer" ] 
#then
#iterateEval.sh | mail -s "Run eval $id - $p" epalmer@psi.edu
#fi
#if [ "$w" == "jweirich" ] 
#then
#iterateEval.sh | mail -s "Run eval $id - $p" jweirich@psi.edu
#fi

############################
# Track correlation
############################
# Set -- 
#    map=000005
if [ -e config/nftID ]
then
	# Get the name of the feature
	source config/nftID
   map=${nft}${res}
	echo "map source $map" >> notes

	# Get directories ready
	dir=log/$map/run-$id
	mkdir -p $dir
   name=${nft}A

	# Build the bigmap with ref for significant digits
	echo $name > tmp
	cat nftConfig/nftBigmap-$nft-$res.IN >> tmp
	bigMapRef < tmp

	# show the map
	echo $name | showmap
	convert $name.pgm $dir/$name-$id.jpg

	# Get sigmas
	convert SIGMAS.pgm $dir/SIGMA-$name-$id.jpg
	/bin/echo -n "SIGMAS.TXT:  " >> notes
	tail -2 SIGMAS.TXT | head -1 >> notes


	# Get find_nofit Data
	find_nofitP > fit
	/bin/echo -n "No Fits - correlation:  " >> notes
	wc fit >> notes
	/bin/echo -n "No Fits - Errors (redo):  " >> notes
	wc redo.txt >> notes
	/bin/cp fit $dir

	# Get corrEval
	corrEval.sh | tail -4 >> notes
	/bin/cp evalResults/ $dir

	#/bin/echo -n "MAPINFO.TXT:  " >> notes
	#grep RMS MAPINFO.TXT >> notes
	#/bin/echo -n "RESIDUALS.TXT:  " >> notes
	#grep RMS RESIDUALS.TXT >> notes
	#/bin/echo -n "Chevrons:  " >> notes
	#grep ">" RESIDUALS.TXT | wc >> notes
	

	# Clean up files
	mkdir -p $dir/oot
	mv *OOT $dir/oot/
	echo y | cp MAPFILES/$map.MAP $dir/$map-$id.MAP
fi



# See if you should continue or shutdown
if [ -e config/stopCount ]
then
# shutdown
	stop=`cat config/stopCount`
	echo "Checking auto stop:  $stop and $id " >> notes
	if [ "$id" == "$stop" ]
	then
		echo "Count matches, shuting down" | tee -a notes

		echo "Running residuals" | tee -a notes
		echo 7 .0005 .0005 | RESIDUALS

		pid=`ps x | grep monitord.sh | grep -v grep | cut -c 1-6`
		cmnd="kill -9 $pid"				# this command should be done at the end of the script (last line)
		echo $cmnd | tee -a notes	# note - nothing will run after this executes


      finished nft-$nft-iteration-$id-done
	else
		mkdir -p ../del
		/bin/mv -f *OOT ../del
	fi

# Looking for a better way to test
#echo "Extra eval $id vs. $stop" | tee -a notes
#	if [ "$id" -lt "$stop" ]
#	then
#		echo "ID is less" | tee -a notes
#		echo "Continue" | tee -a notes
#	fi
#
#	if [ "$stop" -le "$id" ]
#	then
#		echo "stop is less" | tee -a notes
#		echo "End has been found" | tee -a notes
#		echo "You are all done - should shut down" | tee -a notes
#	fi
#
#
fi


####### 
# Die unhappy

redo=`wc -l redo.txt | cut -c -8`
redo=`echo $redo - 1 | bc`
echo "Redo is $redo" >> notes

if [ -e config/starStop ]
	echo "I have the configuration to stop on a star"
	if [ "$redo" == "0" ]
	then
		echo "Iteration is clean (redo.txt - 0)- yay" >> notes
	else
		finished Star-killed-the-run
		cat redo.txt >> notes
		cat redo.txt
		echo "Detected redo and should quit" >> notes
		echo "Count matches, shuting down" | tee -a notes
		pid=`ps x | grep monitord | grep -v grep | cut -c 1-6`
		cmnd="kill -9 $pid"				# this command should be done at the end of the script (last line)
	fi
fi
	
# Do you want to build the shape?
if [ -e config/buildShapeFlag ]
then
	echo "Building shape auto-$id" >> notes
	/opt/local/spc/bin/buildShape.sh auto-$id
	finished shape
fi

## It is now time to die
######
$cmnd | tee -a notes
$cmnd | tee -a notes
$cmnd | tee -a notes
echo "Process hasn't been killed, thus I will survive..." >> notes
echo $cmnd >> notes


