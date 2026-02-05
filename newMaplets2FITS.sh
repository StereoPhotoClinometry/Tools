#!/bin/bash

# This goes through all of the .MAP files in MAPFILES/
# and turns the MAP file into a FITS file if it doesn’t already exist in the /MAPFILES directory.

#
# Usage example:
#   bulkMaplet2fits.sh make-maplets.txt
#

cd MAPFILES/

ls *.MAP > mapfiles_list.tmp

while read line
do
	filename="${line%.*}"
	if [ ! -f "$filename.FITS" ]; then
		echo $filename
   		Maplet2FITS -input-map $filename.MAP -output-fits $filename.FITS   
	fi       
done < mapfiles_list.tmp
rm mapfiles_list.tmp
cd ..



rm SHAPEFILES/*PLT
rm *DAT
