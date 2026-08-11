while read line
do
echo -e "$line\n0\nn\ny\nn" | Display
cp TEMPFILE.pgm ./Display/${line}_withLimbs_0.05.pgm
done <list-of-pics-to-check.txt
