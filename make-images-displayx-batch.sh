while read line
do
echo -e "$line\n0\nn\nn" | displayx
cp TEMPFILE.pgm ./Display/${line}.pgm
done <list-of-pics-to-check.txt