# 27 Sep 2017 - Eric E. Palmer

# Creates log directories and stores stuff that isn't needed 
#	in the working directory

#mkdir -p ../log/limber
#mkdir -p ../log/residuals
#
## Moves stuff used for doing LIMBER
#list="VECS.TXT LMKVECS.TXT LIMBER.IN LIMBVECS.TXT"
#for item in $list
#do
#	if [ -e $item ]
#	then
#		mv $item ../log/limber
#	fi
#done
#
## Moves stuff for RESIDUALS	
#list="MAPINFO.TXT PICINFO.TXT RESIDUALS.TXT LMKVECS.TXT check.txt veto.txt RANGES_SOLVED.TXT EMPTY.TXT no_udpate.txt LIMINFO.TXT MAPCHK.TXT MAPRES.TXT PRUNE.TXT FLATLIST.TXT New_Limbs.in"
#for item in $list
#do
#	if [ -e $item ]
#	then
#		mv $item ../log/residuals
#	fi
#done

# Run standard remove script
if [ -e rem_script.b ]
then
	sh rem_script.b
fi


# Removes temp files
rm -rf tmpOut
rm -f tmp*
rm -f temp*
rm -f view.pgm view.gray view_*.jpg
rm -f seeds.pgm
rm -f slope.pgm
rm -f CSPLOT.TXT CSPLOT.ppm
rm -f fort.*
rm -f tmpl.pgm
rm -f elog.txt

# From batch stuff
rm -f LMRK_DISPLAY[01][0-9].pgm
rm -f TESTFILES/*
rm -f TESTFILES1/*
rm -f USED_MAPS.TXT
rm -f USED_PICS.TXT
rm -f INSIDE.TXT
rm -f redo.txt
rm -f rem_script.b

# From RESIDUALS
#rm -f veto.txt
#rm -f redo.txt
#rm -f MAPCHK.TXT
#rm -f ROTATION.TXT
#rm -f PRUNE.TXT
#list="MAPINFO.TXT PICINFO.TXT RESIDUALS.TXT LMKVECS.TXT check.txt veto.txt RANGES_SOLVED.TXT EMPTY.TXT no_udpate.txt LIMINFO.TXT MAPCHK.TXT MAPRES.TXT PRUNE.TXT FLATLIST.TXT New_Limbs.in"

rm -f o a l 
rm -f out
rm -f no_update.txt
rm -f run.sh
#rm -f run.log
rm -f badList
rm -f redoList
rm -f tile-list
rm -f eval*.txt

#clean 	out SHAPEFILES
rm -f SHAPEFILES/TSHP[0-9][0-9].TXT
rm -f SHAPEFILES/SHAPE[1-6].MAP
rm -f SHAPEFILES/dumb*

rm -f shape.gif shape.log

