#!/bin/bash

# -----------------------------------------------------------------------------
# bulk_limber_files.sh
#
# Purpose
# -------
# Run a batch of images through a selected LIMBER executable and save the
# resulting limb vectors for each image into individual output files.
#
# Description
# -----------
# This script reads image names from an input text file, one per line. For each
# image, it:
#
#   1. Creates a temporary LIMBER.TXT input file.
#   2. Executes the selected LIMBER variant:
#        - SATANICLIMBER
#        - DEMONICLIMBER
#        - DARTHLIMBER
#   3. Extracts the first three columns from LIMBVECS.TXT.
#   4. Removes LIMBER control text (e.g., END records).
#   5. Converts FORTRAN-style exponents (D) to standard scientific notation (E).
#   6. Writes the processed output to <image_name>.limb.
#   7. Moves the output file into the LIMBSBMT directory.
#
# Usage
# -----
#   bulk_limber_files.sh <input_file> <mode>
#
# Arguments
# ---------
#   input_file
#       Text file containing one image name per line.
#
#   mode
#       LIMBER executable to run. Accepted values:
#         satanic | SATANICLIMBER
#         demonic | DEMONICLIMBER
#         darth   | DARTHLIMBER
#
# Example
# -------
#   ./bulk_limber_files.sh image_list.txt satanic
#
# Output
# ------
#   Creates a LIMBSBMT directory (if it does not already exist) and stores
#   one .limb file per input image:
#
#       LIMBSBMT/<image_name>.limb
#
# Warnings
# --------
#   - This script overwrites LIMBER.TXT and LIMBVECS.TXT during execution.
#   - Existing files with those names may be lost.
#   - The user is prompted for confirmation before processing begins.
#
# Dependencies
# ------------
#   - awk
#   - perl
#   - SATANICLIMBER, DEMONICLIMBER, or DARTHLIMBER executable available in
#     the user's PATH.
#
# Authors
# -------
#   Created: 25 October 2021 by Carolyn Ernst
#   Modified: 15 June 2026 by Carolyn Ernst
# -----------------------------------------------------------------------------

FLAVOR=""

read -p "Running this program will overwrite LIMBVECS.TXT and LIMBER.TXT. Are you sure you want to proceed? (y/n) " answer

if [ "$answer" == "n" ]; then
    echo "Cancelling script!"
    exit 0
fi

if [ -d LIMBSBMT ]; then
    echo "Directory LIMBSBMT exists."
else
    echo "Directory LIMBSBMT does not exist - creating it now."
    mkdir LIMBSBMT
fi

case "$2" in
    satanic|SATANICLIMBER)
        echo "Running satanic limber"
        FLAVOR='SATANICLIMBER'
        ;;
    demonic|DEMONICLIMBER)
        echo "Running demonic limber"
        FLAVOR='DEMONICLIMBER'
        ;;
    darth|DARTHLIMBER)
        echo "Running darth limber"
        FLAVOR='DARTHLIMBER'
        ;;
    *)
        echo "Please choose what type of limber you wish to run: satanic, demonic, or darthLimber."
        exit 1
        ;;
esac

while read -r line
do
    echo "${line}"

    echo " ${line}" > LIMBER.TXT
    echo "END" >> LIMBER.TXT

    "${FLAVOR}"

    awk '{ print $1, $2, $3 }' LIMBVECS.TXT | tail -n +2 > "${line}.limb"
    perl -p -i -e "s/END//g" "${line}.limb"
    perl -p -i -e "s/D/E/g" "${line}.limb"

    mv "${line}.limb" "LIMBSBMT/"

done < "$1"

rm -f "LIMBSBMT/END.limb"
