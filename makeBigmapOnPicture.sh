#!/bin/bash

# 23 February 2023 - Terik Daly
#                    Pulled together from existing scripts to
#                    make bigmap tiling inputs for lat lon
#                    and apply those to work with a bigmap based on a
#                    pixel/line location in an image. The bigmap GSD
#                    and maplet GSD are arguments, which makes this
#                    script rather flexible. The image name and pixel
#                    line location are also arguments.

# Makes a dense bigmap using the cookbook steps.

# Example: support/makeBigmapOnPicture.sh D7175061210G 388 722 0.0000625 175 0.0001 0.00005 support/XXX0.00005.SEED -d

# That will create a bigmap at pixel line location 456 409 in the image D7175061210G using the -d (dense) option.
# The bigmap GSD is 0.0000625 km, the bigmap halfsize is 175, the max scale of maplets
# used to make the bigmap is 0.0001, and the maplets to be made have a GSD of 0.00005.
# The tiling seed will be XXX0.00005.SEED.

# The script will name the bigmap 456409.

# Give the input arguments useful names.

imageName=$1
pixel=$2
line=$3
bigmapGSD=$4 # in units of km
halfSize=$5
maxScale=$6
mapletScale=$7 # in units of km
tileSeed=$8
tileOpt=${9:--d}

# The bigmap name will be the six character pixel/line location of the bigmap center
mapname=${2}${3}

if [ -d "bigmap" ]
then
    echo "Directory bigmap exists."
else
    echo "Error: Directory bigmap does not exists - creating it now."
    mkdir bigmap
fi

# make the bigmap input file
echo "p" >bigmap/bigmap.tmp
echo "${imageName}" >>bigmap/bigmap.tmp
echo "${pixel} ${line}" >>bigmap/bigmap.tmp
echo "${bigmapGSD} ${halfSize} 2345 ${maxScale}" >>bigmap/bigmap.tmp
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

# link the bigmap to XXXXXX
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
open ./bigmap/${mapname}_slope_$(date +%FT%H%M).png

cp SIGMAS.TXT ./bigmap/${mapname}_SIGMAS_$(date +%FT%H%M).TXT
cp USED_MAPS.TXT ./bigmap/${mapname}_USED_MAPS_$(date +%FT%H%M).TXT
cp USED_PICS.TXT ./bigmap/${mapname}_USED_PICS_$(date +%FT%H%M).TXT
cp INSIDE.TXT ./bigmap/${mapname}_INSIDE_$(date +%FT%H%M).TXT

# determine coverage of bigmap at desired maplet scale
echo -e XXXXXX >map_coverage.tmp
echo -e ${mapletScale} ${mapletScale} >>map_coverage.tmp
map_coverage <map_coverage.tmp
convert coverage_m.pgm ./bigmap/${mapname}_${mapletScale}kmGSD_$(date +%FT%H%M).png
open ./bigmap/${mapname}_${mapletScale}kmGSD_$(date +%FT%H%M).png


# make the tilefile based on that coverage (this uses
# the make dense option)
echo -e "n\n" | make_tilefile -d | tee tmp
echo XXXXXX > lsupport/bigmap_tile.in
echo ${tileSeed} >> lsupport/bigmap_tile.in
sed 1,2d tmp >> lsupport/bigmap_tile.in
support/relink.sh lsupport/bigmap_tile.in make_scriptT.in

# rm files so I don't get confused
rm XXXXXX.pgm
rm slope.pgm
rm SIGMAS.TXT
rm SIGMAS_${mapname}.FITS
rm WEIGHTS_${mapname}.FITS
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

echo "support/makeBigmapOnPicture.sh ${mapname}_$(date +%FT%H%M)." | tee -a notes
echo "Finished making bigmap tiling inputs for ${mapname}_$(date +%FT%H%M)." | tee -a notes
