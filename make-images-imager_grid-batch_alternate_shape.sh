while read line
do
echo -e "$line\ny\nSHAPEFILES/SHAPE_THOMAS.TXT\nn" | imager_grid
cp TEMPFILE.pgm ./Display/${line}_Thms.pgm
done <list-of-pics-to-check.txt
