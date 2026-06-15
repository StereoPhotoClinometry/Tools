#!/bin/bash

# This goes through all of the LMKs listed in the input argument
# and turns the MAP file into a FITS file in the /MAPFILES directory.
# The input file must be formatted like LMRKLIST (the name of the maplet
# with no preceeding space). But, it doesn't need an end because there is
# no maplet named END.
#
# Usage example:
#   bulkMaplet2fits.sh make-maplets.txt
# 
# Comments added 1/14/21 by Terik Daly

cd MAPFILES/
while read line
do
	Maplet2Fits -input-map ${line}.MAP -output-fits ${line}.FITS
done < ../${1}
cd ..

rm SHAPEFILES/*PLT
rm *DAT
