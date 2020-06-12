
file=$1

echo $file

/opt/local/spc/alt/Maplet2FITS MAPFILES/$1.MAP  f
/opt/local/spc/alt/FITS2OBJ --local f $1.obj


