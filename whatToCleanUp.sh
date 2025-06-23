#!/bin/bash

# Terik Daly
# 27 Sep 2021
# Run this script at the end of an iteration to make sure nothing
#    nasty happened and get info into the notes that will be useful
#    for troubleshooting and cleaning things up.

support/grepNasty.sh
find_nofit
echo 'redo.txt following iteration contained' >>notes
cat redo.txt | tee -a notes
echo "end of redo.txt" >>notes
support/iterateEval.sh
echo "here come the Running" >>notes
grep "Running" eval/evalOut.txt | tee -a notes
echo "end of Running" >>notes
echo "here come the nofits" >>notes
grep "nofit" eval/evalOut.txt | sort -k2 | tee -a notes
echo "end of nofits" >>notes
