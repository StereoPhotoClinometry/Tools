#!/bin/bash
#
# Usage:
#   quickMaplet2Fits.sh MAPLETNAME
#     - Runs Maplet2Fits from the Terrasaur package on a single maplet
#
# Examples:
#   ./quickMaplet2Fits.sh CE0001
#
# Author: Carolyn Ernst
# Version: 1.0
# Last Modified: 2026-01-23

cd MAPFILES/
Maplet2FITS -input-map ${1}.MAP -output-fits ${1}.FITS
cd ..
