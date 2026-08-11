#!/bin/bash

if [ -d "residualsOutputs" ]
then
    echo "Directory residualsOutputs exists."
else
    echo "Error: Directory residualsOutputs does not exists - creating it now."
    mkdir residualsOutputs
fi

echo -e "$1 $2 $3 $4" | residualsX1 >residualsLog.txt
open residualsLog.txt

cp RESIDUALS.TXT ./residualsOutputs/RESIDUALSx_$(date +%FT%H%M)_${4}.TXT
cp MAPINFO.TXT ./residualsOutputs/MAPINFOx_$(date +%FT%H%M)_${4}.TXT
cp PICINFO.TXT ./residualsOutputs/PICINFOx_$(date +%FT%H%M)_${4}.TXT

grep "RMS Residual (m)" RESIDUALS.TXT | tee -a notes
grep "RMS POSITION UNCERTAINTY" MAPINFO.TXT | tee -a notes

# make a plot of residual for each version, which is sort of 
# like time

grep "RMS Residual (m)" residualsOutputs/RESIDUALSx* | awk '{ print $6 }' >residuals.dat
grep "RMS POSITION UNCERTAINTY" residualsOutputs/MAPINFOx* | awk '{ print $6 }' >mapinfo.dat

gnuplot -p -e 'plot "residuals.dat"'
gnuplot -p -e 'plot "mapinfo.dat"'
