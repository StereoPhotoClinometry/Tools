#!/bin/bash

# 21 May 2024, Ally Glantzberg: script to make bigmaps
# and bigmap tiling inputs with user-specified inputs

# 26 May 2021, made this from tileBigmap.sh to make 10-m
# GSD maplets, specifically.

# 10 Sep 2021 updated to copy additional bigmap outputs
# into the bigmap directory.

# 20 Sep 2021 updated file names to include date string for traceability.

# 12 Oct 2022 updated for 10cm maplets for DART. This uses the dense option in 
# make_tilefile

# Example: support/tileBigmap_LatLon.sh -15 210 0.000125 175 0.00025 0.0001 seed_file.seed

# This will make a bigmap named n15210 at -15 latitude, 210 degrees longitude. 
# The maplet GSD is 0.0001 km (10 cm), the half-size is 175
# and the max scale is 0.00025 km (i.e., 25 cm). It produces tiling inputs for 0.0001 km
# (10 cm) maplets
# last argument is the name of the seed file (relative path to) used too build landmarks

if [ $1 -lt 0 ]
then
    mapname=n${1#-}${2#-}
else
    mapname=0$1${2#-}
fi

latitude=$1
longitude=$2
GSD=$3 # in units of km
halfSize=$4
maxScale=$5
mapletScale=$6 #in units of km
seed_file=$7


if [ -d "bigmap" ]
then
    echo "Directory bigmap exists."
else
    echo "Error: Directory bigmap does not exists - creating it now."
    mkdir bigmap
fi

# make the bigmap input file
echo "l" >bigmap/bigmap.tmp
echo "${latitude} ${longitude}" >>bigmap/bigmap.tmp
echo "${GSD} ${halfSize} 2345 ${maxScale}" >>bigmap/bigmap.tmp
echo "${mapname}" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "0.005" >>bigmap/bigmap.tmp
echo "0.025" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "1" >>bigmap/bigmap.tmp
echo "0" >>bigmap/bigmap.tmp
echo "0" >>bigmap/bigmap.tmp

# build the bigmap
BIGMAP <bigmap/bigmap.tmp

# link the bigmap to XXXXXX and make inputs.
cd MAPFILES
../support/relink.sh ${mapname}.MAP XXXXXX.MAP
cd ..

# Make a FITS file
Maplet2FITS MAPFILES/${mapname}.MAP MAPFILES/${mapname}.FITS

# Look at the map
echo XXXXXX | SHOWMAP
convert XXXXXX.pgm ./bigmap/${mapname}_$(date +%FT%H%M).png

open ./bigmap/${mapname}_$(date +%FT%H%M).png
convert SIGMAS.pgm ./bigmap/${mapname}_SIGMAS_$(date +%FT%H%M).png
open ./bigmap/${mapname}_SIGMAS_$(date +%FT%H%M).png
convert slope.pgm ./bigmap/${mapname}_slope_$(date +%FT%H%M).png
cp SIGMAS.TXT ./bigmap/${mapname}_SIGMAS_$(date +%FT%H%M).TXT
cp USED_MAPS.TXT ./bigmap/${mapname}_USED_MAPS_$(date +%FT%H%M).TXT
cp USED_PICS.TXT ./bigmap/${mapname}_USED_PICS_$(date +%FT%H%M).TXT
cp INSIDE.TXT ./bigmap/${mapname}_INSIDE_$(date +%FT%H%M).TXT

# determine coverage of bigmap at desired maplet scale
#rm map_coverage.tmp
echo -e XXXXXX >map_coverage.tmp
echo -e ${mapletScale} ${mapletScale} >>map_coverage.tmp
map_coverage <map_coverage.tmp 
#rm map_coverage.tmp
convert coverage_m.pgm ./bigmap/${mapname}_${mapletScale}kmpreCoverage_$(date +%FT%H%M).png 
open ./bigmap/${mapname}_${mapletScale}kmpreCoverage_$(date +%FT%H%M).png


# make dense tilefile based on that coverage 
echo -e 'n\n' | make_tilefile -d > tmp
echo XXXXXX > lsupport/bigmap_tile.in
echo ${seed_file} >> lsupport/bigmap_tile.in
sed 1,2d tmp >> lsupport/bigmap_tile.in
support/relink.sh lsupport/bigmap_tile.in make_scriptT.in

# rm files so I don't get confused
rm XXXXXX.pgm
rm slope.pgm
rm SIGMAS.TXT
rm USED_MAPS.TXT
rm USED_PICS.TXT
rm INSIDE.TXT

# Remove preexisting INNs, OOTs, run_scripts, and TESTFILES, as well as LMRKLIST1.TXT
# (the latter so you know you always have a fresh one, if you tiled previously).

rm -f *.INN
rm -f *.OOT
rm -f run_script*
chmod +x rem_script.b
./rem_script.b
rm -f ./TESTFILES/*
rm -f ./TESTFILES1/*
rm LMRKLIST1.TXT
echo END >LMRKLIST1.TXT
MAKE_LMRKLISTX

echo "support/tileBigmap_LatLon.sh ${mapname}_$(date +%FT%H%M)." | tee -a notes
echo "Finished making bigmap tiling inputs for ${mapname}_$(date +%FT%H%M)." | tee -a notes
echo "GSD=${GSD} km " |tee -a notes 
echo "half size = ${halfSize}" | tee -a notes
echo "max scale = ${maxScale}" | tee -a notes
echo "maplet scale = ${mapletScale} km" | tee -a notes
echo "seed file = ${seed_file} " | tee -a notes





