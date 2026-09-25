#!/bin/bash -f 

delete_these_now=$1

while read line
do 
echo d
echo $line
echo 1
echo y
done < $delete_these_now > delete_empty.txt | lithos < delete_empty.txt
