while read line
do
echo -e "n\n$line\nn" | imager_mg
cp TEMPFILE.pgm ./Display/${line}_MG.pgm
done <list-of-pics-to-check.txt
