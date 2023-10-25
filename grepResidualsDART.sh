#!/bin/bash

# Terik Daly
# 30 March 2021
# This script greps for flags in MAPINFO, PICINFO, and RESIDUALS.TXT that indicate 
     # problems with maplets or images and adds maplets or images that match those 
     # criteria to the notes file.
# It is designed to make reviewing the residuals outputs a bit easier.

# Updated 5 January 2022 to print maplets with 10 fewest overlaps, and 10 largest
#    dHT and mxslp.

# Updated 19 Oct 2023 to print maplets with the 10 fewest limbs.

echo 'Grepping MAPINFO.TXT' | tee -a notes
echo '>> means high pixel residual' | tee -a notes
grep ">>" MAPINFO.TXT | tee -a notes

echo '** means three or fewer images in LMK' | tee -a notes
grep "\*\*" MAPINFO.TXT | tee -a notes

echo 'Here are the maplets with the top 10 UNC(M)' | tee -a notes
echo 'MAPLET UNC(M)' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $10 }' | sort -k 2 -n -r | head | tee -a notes

echo 'Here are the 10 maplets with the fewest overlaps' | tee -a notes
echo 'MAPLET OVERLAPS' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $8 }'| sort -k 2 -n | head | tee -a notes

echo 'Here are the 10 maplets with the fewest limbs:' | tee -a notes
echo 'MAPLET LIMBS' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $9 }'| sort -k 2 -n | head | tee -a notes

echo 'Here are the maplets with the largest dHT' | tee -a notes
echo 'MAPLET dHT' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $14 }' | sort -k 2 -n -r | head | tee -a notes

echo 'Here are the maplets with the largest mxslp' | tee -a notes
echo 'MAPLET mxslp' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $13 }' | sort -k 2 -n -r | head | tee -a notes

echo 'End of MAPINFO.TXT grep' | tee -a notes

echo 'Grepping RESIDUALS.TXT' | tee -a notes
grep ">>" RESIDUALS.TXT | tee -a notes
grep "<<" RESIDUALS.TXT | tee -a notes
echo 'End of RESIDUALS.TXT grep' | tee -a notes

echo 'Grepping PICINFO.TXT' | tee -a notes
echo '> means pixel residual greater than limit' | tee -a notes
grep ">" PICINFO.TXT | tee -a notes
echo '* means 3 or fewer LMKs in the image' | tee -a notes
echo 'this ignores images with 0 LMKs' | tee -a notes
grep "\*" PICINFO.TXT | awk '{ print $1, $8 }' | grep -v " 0" | tee -a notes
echo 'End of PICINFO.TXT grep'| tee -a notes
