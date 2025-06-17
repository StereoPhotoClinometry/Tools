#!/bin/bash

# Terik Daly
# 30 March 2021
# This script greps for flags in MAPINFO, PICINFO, and RESIDUALS.TXT that indicate 
     # problems with maplets or images and adds maplets or images that match those 
     # criteria to the notes file.
# It is designed to make reviewing the residuals outputs a bit easier.

# Updated 5 January 2022 to print maplets with 10 fewest overlaps, and 10 largest
#    dHT and mxslp.

# Updated November 2023 to fix a bug in the dHT and mxslp sections

# Update 30 November 2023 to add additional info and formatting

echo '------------------------------------' | tee -a notes
echo 'grepResiduals run on' $(date +%FT%H%M) | tee -a notes
echo '------------------------------------' | tee -a notes

echo 'Grepping MAPINFO.TXT' | tee -a notes
echo '** means three or fewer images in LMK' | tee -a notes
echo 'try adding new images to LMK and iterate' | tee -a notes
grep "\*\*" MAPINFO.TXT | tee -a notes

echo '>> means high pixel residual' | tee -a notes
echo 'try v/2, realign, iterate' | tee -a notes
grep ">>" MAPINFO.TXT | tee -a notes

echo 'Here are the maplets with the top 10 UNC(M)' | tee -a notes
echo 'Check outliers in lithos' | tee -a notes
echo 'MAPLET UNC(M)' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $10 }' | sort -k 2 -n -r | head | tee -a notes

echo 'Here are the 10 maplets with the fewest overlaps' | tee -a notes
echo 'Check 0 overlaps and outliers in lithos' | tee -a notes
echo 'MAPLET OVERLAPS' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $8 }'| sort -k 2 -n | head | tee -a notes

echo 'Here are the maplets with the largest dHT' | tee -a notes
echo 'Check outliers in lithos' | tee -a notes
echo 'MAPLET dHT' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $NF }' | sort -k 2 -n -r | head | tee -a notes

echo 'Here are the maplets with the largest mxslp' | tee -a notes
echo 'Check outliers in lithos' | tee -a notes
echo 'MAPLET mxslp' | tee -a notes
cat MAPINFO.TXT | sed '1,2d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' |sed '$d' | sed '$d' | sed '$d' | sed '$d' | sed '$d' | awk '{ print $1, $(NF-1) }' | sort -k 2 -n -r | head | tee -a notes

echo 'End of MAPINFO.TXT grep' | tee -a notes

echo 'Grepping RESIDUALS.TXT' | tee -a notes
echo 'These LMKs have residuals that exceed the specified limit' | tee -a notes
echo 'v/2, realign, iterate; consider checking for new images' | tee -a notes
grep "<<" RESIDUALS.TXT | tee -a notes


echo 'This flags images, overlaps, and limbs that exceed the limit' | tee -a notes
echo 'Do not worry about overlaps and limbs in a pinch, can veto them' | tee -a notes
echo 'For images in LMKs, check alignment carefully' | tee -a notes
grep ">>" RESIDUALS.TXT | tee -a notes
echo 'End of RESIDUALS.TXT grep' | tee -a notes

echo 'Grepping PICINFO.TXT' | tee -a notes
echo 'Run flagged pictures through autoregister' | tee -a notes
echo '* means 3 or fewer LMKs in the image' | tee -a notes
echo 'this ignores images with 0 LMKs' | tee -a notes
echo 'Picture     Image time     Pixel scale    Number of LMKs    Number of limbs    Flags     Pixel residual    camera and twist residuals   finally, phase angle' | tee -a notes
grep "\*" PICINFO.TXT | awk '{ print $1, $8 }' | grep -v " 0" | tee -a notes

echo '> means pixel residual greater than limit' | tee -a notes
grep ">" PICINFO.TXT | tee -a notes
echo 'End of PICINFO.TXT grep'| tee -a notes


echo '------------------------------------' | tee -a notes
echo 'End of grepResiduals' | tee -a notes
echo '------------------------------------' | tee -a notes

