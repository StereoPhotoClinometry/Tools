#!/bin/bash

# Terik Daly
# 30 April 2021
# This script greps for NaNs and images that have gone bonkers in LMK and SUM files
     # as well as in OOTs.
# It is designed to make it easier to tell is something went bonkers after a 
     # geometry or an iteration..

echo 'Grepping NaN from SUMFILES' | tee -a notes
grep 'NaN' SUMFILES/* | tee -a notes

echo 'Grepping NaN from LMKFILES' | tee -a notes
grep 'NaN' LMKFILES/* | tee -a notes

echo 'Grepping NaN from OOTs' | tee -a notes
grep 'NaN' *OOT | tee -a notes

echo 'Grepping OOTS for crazy images' | tee -a notes
grep "     90.00      0.00      0.00      0.00       " *OOT | tee -a notes
echo 'End of greps' | tee -a notes

#echo 'Grepping unfinished LMKs from OOTs' | tee -a notes
#grep -L ‘DONE’ *.OOT | tee -a notes

rm SHAPEFILES/*PLT
rm *DAT
