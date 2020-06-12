#!/bin/sh
# plotSCOBJ.sh
# DLambert 06/15/16
# companion script to getSCOBJ.sh
# script plots the available SCOBJ for a single user-defined picture

# This script should be executed from the working directory, or at least the directory which
# contains the 'scobj' subdirectory (see getSCOBJ.sh).
#
# The user must enter the name of a picture on the command line eg:
# sh plotSCOBJ.sh P596677398F0
#
# plotSCOBJ.sh will dump a png file in the 'scobj' directory and open the plot in the
# X11 terminal
#
# Options:
# g: plotSCOBJ.sh generates a GIF which it places in scobj/

version=1.0

flagGif=0
while getopts ":g" options; do
	case $options in
	g)
		flagGif=1;;
	\?)
		echo "Error: invalid option!";;
	esac
done
shift $((OPTIND-1))
picNm=`echo $1 | cut -d '.' -f 1`

# Misuse trap
if [ "${picNm}X" == "X" ]; then
        echo "Usage: $0 <picture name> (required)"
        echo "Example 1: $0 P596677398F0"
        exit
fi

# Check scobj directory exists
if [ ! -d ./scobj ]; then
        echo "scobj directory does not exist."
        echo "Please run script from within working directory. Exiting."
        exit
fi

# Check log file exists
if [ ! -f scobj/${picNm}_scobj_cz.log ]; then
	echo "${picNm}_scobj_cz.log file is not contained in scobj/ , exiting."
        exit
fi

# Generate plotting files
rm -f scobj/*.tmp
while read line; do

	if [ `echo $line | grep ^\# | wc -l` -eq 0 ]; then
		stateID=`echo $line | awk '{print $7}'`
		if [ ! -f scobj/${picNm}_${stateID}.tmp ]; then
			echo $line | awk '{print $1,$2,$3}' > scobj/${picNm}_${stateID}.tmp
		echo ${picNm}_${stateID}.tmp >> scobj/listPlotFiles.tmp
		else
			count=1
			flagFileStored=0
			while [ $flagFileStored -eq 0 ]; do
				let count+=1
				if [ ! -f scobj/${picNm}_${stateID}${count}.tmp ]; then
					echo $line | awk '{print $1,$2,$3}' > scobj/${picNm}_${stateID}${count}.tmp
					echo ${picNm}_${stateID}${count}.tmp >> scobj/listPlotFiles.tmp
					flagFileStored=1
				fi
			done
		fi
	fi

done < scobj/${picNm}_scobj_cz.log

# Build gnuplot input file
printf "%-s\n" "set term x11" > scobj/${picNm}_gnuplot.in
printf "%-s\n" "set title \"$picNm spacecraft position\"" >> scobj/${picNm}_gnuplot.in
printf "%-s" "splot " >> scobj/${picNm}_gnuplot.in
flagFirstLine=1
while read line; do
	titleID=`echo $line | cut -d '.' -f 1 | rev | cut -d '/' -f 1 | rev | cut -c14-`
	if [ $flagFirstLine -eq 1 ]; then
		printf "%-s" "'scobj/$line' with points pt 7 ps 2 title \"$titleID\"" >> scobj/${picNm}_gnuplot.in
		flagFirstLine=0
	else
		printf "%-s\n%-s" ',\' "'scobj/$line' with points pt 7 ps 2 title \"$titleID\"" >> scobj/${picNm}_gnuplot.in
	fi
done < scobj/listPlotFiles.tmp
printf "\n" >> scobj/${picNm}_gnuplot.in

gnuplot -persist < scobj/${picNm}_gnuplot.in 2>/dev/null

# Generate png
cat scobj/${picNm}_gnuplot.in > scobj/${picNm}_png_gnuplot.in
echo "set term png" >> scobj/${picNm}_png_gnuplot.in
echo "set terminal png size 1024,768" >> scobj/${picNm}_png_gnuplot.in
echo "set output \"scobj/${picNm}_scobj.png\"" >> scobj/${picNm}_png_gnuplot.in
echo "replot" >> scobj/${picNm}_png_gnuplot.in
echo "exit" >> scobj/${picNm}_png_gnuplot.in
gnuplot < scobj/${picNm}_png_gnuplot.in 2>/dev/null
echo "scobj/${picNm}_scobj.png generated."

echo "scobj/${picNm}_gnuplot.in generated. Copy commands into gnuplot for an interactive plot."

# Generate GIF if option selected
if [ $flagGif -eq 1 ]; then

	# Clean scobj/
	rm -f scobj/scobj*.png

	# Build gnuplot gif input file
	cat scobj/${picNm}_gnuplot.in > scobj/${picNm}_gif_gnuplot.in
	printf "%-s\n%-s\n" "set term png" "set terminal png size 1024,768" >> scobj/${picNm}_gif_gnuplot.in
	count=0
	for i in $(seq 0 10 350); do
		let count+=1
		if [ $count -lt 10 ]; then
			filename=scobj0$count
		else
			filename=scobj$count	
		fi
		echo "set output \"scobj/${filename}.png\"" >> scobj/${picNm}_gif_gnuplot.in
		echo "set view 60, $i, 1, 1" >> scobj/${picNm}_gif_gnuplot.in
		echo "replot" >> scobj/${picNm}_gif_gnuplot.in 
	done
	echo "exit" >> scobj/${picNm}_gif_gnuplot.in
	
	# Generate plots
	gnuplot < scobj/${picNm}_gif_gnuplot.in 2>/dev/null

	# Make GIF
	convert -delay 20 -loop 0 scobj/scobj*.png scobj/${picNm}_scobj.gif
	echo "scobj/${picNm}_scobj.gif generated."

	# Clean scobj/
        rm -f scobj/scobj*.png
fi
