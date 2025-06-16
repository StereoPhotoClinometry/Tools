# Terik Daly
# 29 March 2021
# This is designed for satanic SPC.
# It makes several different real and fake images to compare different models to each other
#    and to images. 

# Run Display to make the real image.
while read line
do
echo -e "${line}\n0\nn\nn\n" | Display
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_R.png

# Run imager_grid on the shape used in the Phobos paper.
#echo -e "${line}\ny\nSHAPEFILES/SHAPE3_201216_lt0.05GSD-maplets-only.TXT\nn" | imager_grid
#convert TEMPFILE.pgm TEMPFILE.png
#cp TEMPFILE.png ./Display/${line}_paperShape.png

# Run imager_grid on the Bob fix shape
#echo -e "${line}\ny\nSHAPEFILES/SHAPE3_210320_postEqualize_lt0.025GSD-maplets-only.TXT\nn" | imager_grid
#convert TEMPFILE.pgm TEMPFILE.png
#cp TEMPFILE.png ./Display/${line}_bobFixShape.png

# Run imager_grid on the new shape.
echo -e "${line}\ny\nSHAPEFILES/SHAPE3_partial10mGSDtiles_2021-08-03.TXT\nn" | /usr/local/bin/spc/satanic/bin/imager_grid
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_unitedPartial10mGSDShape.png

# Run imager_mg to see what the mapletslook like.
echo -e "n\n${line}\nn" | /usr/local/bin/spc/satanic/bin/imager_mg
convert TEMPFILE.pgm TEMPFILE.png
cp TEMPFILE.png ./Display/${line}_unitedPartial10mGSD.png

done <$1
