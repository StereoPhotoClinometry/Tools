#!/usr/bin/env bash
#
# Usage:
#   grepMAPINFO.sh MAPLET
#     - Grep MAPINFO.TXT for a single maplet
#
#   grepMAPINFO.sh -f LISTFILE
#     - Grep MAPINFO.TXT once for each maplet listed in LISTFILE
#     - One maplet per line
#     - Processing stops at the end of the file or when the line "END" is encountered
#
# Examples:
#   ./grepMAPINFO.sh CE0001
#   ./grepMAPINFO.sh -f maplets.txt
#
# Author: Carolyn Ernst
# Version: 1.0
# Last Modified: 2026-01-22

# One argument: original behavior
if [ "$#" -eq 1 ]; then
  grep "$1" MAPINFO.TXT
  exit 0
fi

# Two arguments: loop over file
while IFS= read -r maplet; do
  [ "$maplet" = "END" ] && break
  grep "$maplet" MAPINFO.TXT
done < "$2"
