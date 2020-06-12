#!/bin/sh
# transposeFile.sh
# Diane Lambert 10/29/15
# This script transposes the contents of a text file. 
# It is expected that the text file contains a matrix of data, delimited by commas, spaces and/or tabs.
# The tranposed data are written to a text file and the user is notified.
# The intended purpose is to transpose horizontal transits for plotting with Gnuplot.

# Define read-from filename
if [[ ! -z $1 ]]; then
  readFromFN=$1
else
  echo FILENAME:
  read readFromFN
fi

# Check that file exists
if [[ -s $readFromFN ]]; then
  echo File found - transposing ...

  # Define write-to filename
  writeToFN="$(echo $readFromFN | awk -F'[.]' '{ print $1 }')-transposed.txt"

  # Extract Data

  r=1
  while read -r line || [[ -n "$line" ]];do  
    numCols=$(echo $line | awk '{ print NF }')

    for c in $(seq 1 1 $numCols); do
      value="$(echo $line | awk '{ print "\t",$'"$c"' }')"
      eval "arrayVal${c}[$r]=$(echo $value)"
    done

    let "r+=1"
  done < $readFromFN
  numRows=$r

  # Transpose data and write to output file
  rm -f $writeToFN

  for c in $(seq 1 1 $numCols); do
    stringRow=""
    for r in $(seq 1 1 $numRows); do
      stringRow="$stringRow $(eval echo '${arrayVal'"${c}"'['"$r"']}')"
    done
    echo $stringRow >> $writeToFN
  done

  # Notify user
  echo Transposition complete: $writeToFN

else
  echo File not found
fi

