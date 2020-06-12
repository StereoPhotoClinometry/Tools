#!/bin/sh
# getSCOBJ.sh
# DLambert 06/14/16
# script to record current spacecraft position and pointing

# This script should be executed from the working directory, or at least the directory which 
# contains the SUMFILES directory.
#
# The user must enter a one word model state identifier in the command line. eg:
# sh getSCOBJ.sh nominal
#
# The user has the option of also entering the name of a text file which contains  list of
# sumfiles to work on, eg:
#
# list.txt:
# P595650103F0
# P595650136F0
# P595650167F0
#
# sh getSCOBJ.sh nominal list.txt
# 
# If the user has not entered the name of a file list then getSCOBJ.sh will wokr on every 
# SUMFILE in the SUMFILES directory.
#
# getSCOBJ will dump the log files in a directry called 'scobj' - the log files are self-explanatory

version=1.0

stateID=$1
listPics=$2

# Misuse trap
if [ "${stateID}X" == "X" ]; then
	echo "Usage: $0 <model state ID> (required - one word) <list of SUMFILES> (optional)"
	echo "Example 1: $0 registered"
	echo "Example 2: $0 registered listPics.txt"
	exit
fi

# Check SUMFILES directory exists
if [ ! -d ./SUMFILES ]; then
	echo "SUMFILES directory does not exit."
	echo "Please run script from within working directory. Exiting."
	exit
fi

# Check list exists or create list
if [ "${listPics}X" != "X" ]; then
	if [ ! -f $listPics ]; then
		echo "$listPics file does not exist, exiting."
		exit
	fi
else
	ls SUMFILES | cut -d '.' -f 1 > listPics
	listPics=listPics
fi
numFiles=`wc -l $listPics | awk '{print $1}'`

# Check scobj directory exists, make directory if not.
if [ ! -d ./scobj ]; then
 	mkdir ./scobj
fi

count=0
# Get SCOBJ and CZ
while read filename; do

	let count+=1
	echo "Working on $filename ($count of $numFiles files)"

	# Check if log files exist, if not create and add header
	if [ ! -f scobj/${filename}_scobj_cz.log ]; then
		printf "%-8s\t%-8s\t%-8s\t%-8s\t%-8s\t%-8s\t%-8s\t%-8s\n" '#SCOBJ(1)' "SCOBJ(2)" "SCOBJ(3)" "CZ(1)" "CZ(2)" "CZ(3)" "STATE ID" "DATE" >> scobj/${filename}_scobj_cz.log
	fi

	# get SCOBJ and CZ
	SCOBJ=(`awk '/SCOBJ/ {print $1,$2,$3}' SUMFILES/${filename}.SUM | sed 's/D/e/g'`)
	CZ=(`awk '/CZ/ {print $1,$2,$3}' SUMFILES/${filename}.SUM | sed 's/D/e/g'`)

	# Log data
	printf "%-12f\t%-12f\t%-12f\t%-12f\t%-12f\t%-12f\t%-8s\t%-8s\n" "${SCOBJ[0]}" "${SCOBJ[1]}" "${SCOBJ[2]}" "${CZ[0]}" "${CZ[1]}" "${CZ[2]}" "$stateID" "`date`" >> scobj/${filename}_scobj_cz.log

done < $listPics
