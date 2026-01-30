#!/usr/bin/env bash
#
# Usage:
#   grepPICINFO.sh PICNAME
#     - Grep PICINFO.TXT for a single image
#
#   grepPICINFO.sh -f LISTFILE
#     - Grep PICINFO.TXT once for each maplet listed in LISTFILE
#     - One image per line
#     - Processing stops at the end of the file or when the line "END" is encountered
#     - Code ignores preceeding spaces so PICTLIST or equivalent can be used
#
# Examples:
#   ./grepPICINFO.sh VO375B83
#   ./grepPICINFO.sh -f images.txt
#
# Author: Carolyn Ernst
# Version: 1.0
# Last Modified: 2026-01-22

# One argument: original behavior
if [ "$#" -eq 1 ]; then
  grep "$1" PICINFO.TXT
  exit 0
fi

# Two arguments: loop over file
while IFS= read -r image; do
  image="${image#"${image%%[![:space:]]*}"}"  # strip leading whitespace
  [ "$image" = "END" ] && break
  grep "$image" PICINFO.TXT
done < "$2"
