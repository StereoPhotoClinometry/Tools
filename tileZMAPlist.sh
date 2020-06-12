#!/bin/bash
# 28 Feb 2019 - John R. Weirich
# Zmap Tiling wrapper
# Run this in one of the tile directories using MAPLISTtile[1234].TXT


list=`cat $1`


for i in $list
do

	GSD=0.00014
	SCRIPT=XXX014.seed
	bigmapName=$i

	echo $GSD > inputs
	echo $SCRIPT >> inputs
	echo $bigmapName >> inputs

	# Create a symbolic link to the Zmap used for tiling
	cd MAPFILES/
	rm -f XXXXXX.MAP
	ln -s $bigmapName.MAP XXXXXX.MAP
	cd ..

	#Setup tiling
	echo "XXXXXX" > map_coverage.in
	echo 0 >> map_coverage.in
	echo $GSD >> map_coverage.in
	map_coverage < map_coverage.in
	/usr/local/bin/convert coverage_m.pgm $bigmapName-beforeTiling.jpg
	echo "N" | make_tilefile | tee make_tilefile.out
	sed 1d make_tilefile.out > temp.out
	echo "XXXXXX" > make_scriptT.in
	echo "scripts/$SCRIPT" >> make_scriptT.in
	cat temp.out >> make_scriptT.in


	# Build the scripts
	make_scriptT


	# Run the scripts
	nohup sh run_script.b

	# When complete, save the results
	map_coverage < map_coverage.in
	/usr/local/bin/convert coverage_m.pgm $bigmapName-afterTiling.jpg
	find_nofitT | tee output
	mkdir steptile$bigmapName
	tileEval.sh > eval.out
	mv *INN *OOT output eval.out inputs *Tiling.jpg steptile$bigmapName

	# Once evaluation of new landmarks is complete and they are deemed "good" remove temporary files
	rm -f TESTFILES/*
	rm -f TESTFILES1/*

done

