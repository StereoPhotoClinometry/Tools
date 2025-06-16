while read line
do
echo -e "${line}\nn\n11,10,0,10,0.03,0.75\n1024,1024\n0\ny\ny\n1024,1024\n0\nn" | stella
convert TEMPFILE.ppm ./REGFILES/${line}.png
done <${1}