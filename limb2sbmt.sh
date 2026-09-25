#!/bin/bash

# This script converts a LIMBVECS.TXT or PICNAME.limb (my file from bulk_limber_files.sh)
# LIM or equivalent file into 
# something that can be # read into the SBMT. The required arguments are:
# The input file.
# The output filename.
# The format of the file (txt or lim).

# The resulting file cna then be read into the SBMT using the Tracks tab.
# Format=Lidar Point Only (X, Y, Z)

# Carolyn Ernst 10/22/2021

# example:
# ./limb2sbmt.sh LIMBVECS.TXT outfile.txt txt
# or
# ./limb2sbmt.sh VO507A01.LIM outfile.txt lim

if [ $3 == "txt" ]
then
    #echo "Option1 txt."
    awk '{ print $1, $2, $3 }' ${1} | tail -n+2 > ${2}
#elif [ $3 == "lim" ]
#then
    #echo "Option2 limb."
#    awk '{ print $4, $5, $6 }' ${1} | tail -n+2 > ${2}
else 
	echo "Please choose a supported file type."
fi

	perl -p -i -e "s/END//g" ${2}
	perl -p -i -e "s/D/E/g" ${2}

echo "Have a nice day!"
