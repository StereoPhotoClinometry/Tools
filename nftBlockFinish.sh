# Eric E. Palmer - 3 Oct 2019
# Copies things into subdirectories for archving
# Run when a block if finished.
# This is only for NFT features

phase=$1
who=`whoami | cut -c 1-2`

if [ "$phase" == "" ] 
then
	echo "################## ERROR #################"
	echo "No Phase"
	echo "Usage:  <Phase.day>"
	exit
fi

if [ ! -e "../log/$phase" ]
then
	echo "################## ERROR #################"
	echo "Phase $phase does not exist"
	read -p "Create it (y/n)?" choice
	case "$choice" in 
  	y|Y ) 
			echo "Creating $phase";;
  	n|N ) 
			echo "Stopping"
			exit ;;
  	* ) 
			echo "invalid"
			echo "Stopping - try again"
			exit;;
	esac
fi

# Check to see if we are still editing notes
running=`ps | grep vi | grep notes`

if [ "$running" != "" ]
then
	echo
	echo "################## ERROR #################"
	echo "# Are you still editing notes?           #"
	echo "################## ERROR #################"
	exit
fi

if [ ! -e notes ]
then
	echo
	echo "################## ERROR #################"
	echo "# Please create a notes file             #"
	echo "################## ERROR #################"
	exit
fi


# find the sequence number

	touch -f ../log/$phase		# ensure we don't get an error on ls
	tmp=../log/$phase*
	lines=`/bin/ls -d1 $tmp | wc -l`
	read -rd '' newLines <<< "$lines"
	echo "new: " $newLines

	if [ "$newLines" -lt 10 ] 
	then
		outLines=0$newLines
	else
		outLines=$newLines
	fi



# Get from the user which block has been completed
echo "Which block has been finished"

select answer in "tile" "iterate"  "auto" "clean" "eval" "publish" "import" "quit"; do
	# Identify the correct directory for this
	echo $answer

	try=../log/$phase.$outLines$answer

	# Find the next available slot
	if [ -e $try ]
	then
		echo
		echo "################## ERROR #################"
		echo "# Error - I don't have the right path"
		echo "################## ERROR #################"
	else
		path=$try
	fi

	# Found the directory, now make it
	mkdir -p $path

	case $answer in
		tile ) 
			find_nofitT > fit
			tileEval.sh

			cp -f coverage_*.pgm $path
			mv -f eval/* $path
			cp -f make_scriptT.in $path
			tmp=`head -1 make_scriptT.in | tail -1`
			cp -f $tmp.MAP $path
			mv -f *OOT *INN $path
			mv -f TESTFILES/*.pgm $path
			cp -f LMRKLIST1.TXT $path
			str="Tile"
			break;;

		iterate ) 
			find_nofitP > fit
			iterateEval.sh

			mv -f eval/* $path
			cp evalOut.txt $path
			cp make_scriptP.seed $path
			cp redo.txt fit $path
			mkdir -p ../del
			/bin/mv -f *OOT ../del
			str="Iterate"
			break;;

		auto ) 
			autoEval.sh
			cp -f make_script.in $path
			mv -f *INN *OOT $path
			mv -f eval/* $path
			mkdir -p $path/autoEval
			str="Auto"
			break;;

		clean ) 
			cp RESIDUALS.TXT $path
			cp *INFO.TXT $path
			mv -f eval/* $path
			str="Clean"
			break;;

		eval ) 
			cp RESIDUALS.TXT $path
			cp *INFO.TXT $path
			mv -f eval/* $path
			str="Eval"
			break;;

		import ) 
			cp -f make_script.in $path
			cp -f NEW_FILES/LMRKLIST.TXT $path
			grep Comm *.OOT | cut -c 1-17 > tmp
			paste make_script.in NEW_FILES/LMRKLIST.TXT tmp | tee $path/fileLinks.txt
			cp -f fit  $path
			mv -f *OOT *INN $path
			str="Import"
			break;;

		default ) 
			echo "################## ERROR ###########"
			echo "Invalid argument >$answer<"
			exit
			break;;
	esac

done

# Output info to the masterTracker
d=`date`
echo "############# $path $answer #########################" >> ../masterTracker.txt
echo "# $str - $who " >> ../masterTracker.txt
echo "#    | $d " >> ../masterTracker.txt
if [ -e notes ]
then
	cat notes | sed "s/^/#    | /" >> ../masterTracker.txt
fi
/bin/mv -f notes $path


echo "###############################################" >> ../masterTracker.txt

echo $path

