#!/bin/bash

SPICELIB=~/SPC/toolkit/lib/spicelib.a
F77=/usr/local/bin/gfortran
FFLAGS="-O2 -fbounds-check"
AR=/usr/bin/ar

### Don't change anything below this line

BINDIR=BIN
DOCDIR=/usr/local/spc/doc
LIBDIR=/usr/local/lib
PROCDIR=/usr/local/spc/prc
SEEDSDIR=/usr/local/spc/sds
STARSDIR=/usr/local/spc/stars

# Build the COMMON library

# get the list of library source files from AAmake__COMMON_objects.txt
OBJSRCS=$(grep ftn AAmake__COMMON_objects.txt | awk '{for(i=1;i<=NF;i++){ if(match($i,/\.f/)) { print $i } } }')

cd COMMON
rm -f COMMON.a
for file in $OBJSRCS; do
    echo $F77 $FFLAGS -Wall -c $file
    $F77 $FFLAGS -Wall -c $file
    obj=$(basename $file '.f').o
    $AR rc COMMON.a $obj
done
mv COMMON.a ../COMMON.a
rm -f *.o
cd ..

echo "*** Built COMMON.a"

# get the list of source files from AACOMPILE.TXT
SRCS=$(grep ftn AACOMPILE.TXT | grep -v '#' | awk '{for(i=1;i<=NF;i++){ if(match($i,/\.f/)) { print $i } } }')
for file in $SRCS; do
    echo $F77 $FFLAGS $file COMMON.a $SPICELIB -o $BINDIR/$(basename $file ".f")
    $F77 $FFLAGS $file COMMON.a $SPICELIB -o $BINDIR/$(basename $file ".f")
done

sudo cp STARS/* $STARSDIR
sudo cp COMMON.a $LIBDIR
sudo cp PROCEDURES/* $PROCDIR
sudo cp SEEDS/* $SEEDSDIR
sudo cp DOCUMENTS/* $DOCDIR
sudo cp BIN/* /usr/local/bin/

rm -f /usr/local/bin/OLADIF
rm -f /usr/local/bin/ROTW
rm -f /usr/local/bin/ADDIMGFILE
rm -f /usr/local/bin/SHTST
rm -f /usr/local/bin/QUATIMOTO
