# Eric E. Palmer - 9 May 2019
# Puts things on the webserver so we can more easily see it.

id=$1
code=$2

if [ "$id" == "" ]
then
	echo "Missing id"
	echo "Usage $0 <id> (n)"
	exit
fi

if [ "$id" == "" ]
then
	code="X"
fi

w=`whoami`

# Test to see if you are running on a Mac Server, or a normal mac.
path="/Library/Server/Web/Data/Sites/Default/data$code/"
if [ -e $path ];
then
   path="/Library/Server/Web/Data/Sites/Default/data$code/"
   #echo "  Machine:  Server "
else
   path="/Library/WebServer/Documents/data$code/"
   #echo "  Machine:  Local "
fi

# Test to see if the final path exists, error if it doesn't
if [ ! -e $path ];
then
	echo "###########################"
	echo "###########################"
   echo $path does not exit
   exit
fi

if [ ! -e MAPFILES/${id}$code.MAP ];
then
	echo "###########################"
	echo "###########################"
   echo 	MAPFILES/${id}$code.MAP does not exist
   exit
fi

theFile=nftConfig/nftBigmap-$id-A.IN
if [ ! -e $theFile ];
then
	echo "###########################"
	echo "###########################"
   echo 	$theFile does not exist
   exit
fi




d=`date`

extraBin=/opt/local/spc/unsup/unsup_v3_1B2/bin/

echo "Date: `date`" > tmpNFT
echo $theFile >> tmpNFT

# Build the path to put files
mkdir -p $path/$id/
line=`head -4 $theFile| tail -1`
GSD=`echo $line | awk '{print $1}' `
Q=`echo $line | awk '{print $2}' `

#GSD=`echo $line | cut -c 1-10`
#Q=`echo $line | cut -c 12-15`

pict=`head -2 $theFile| tail -1`
echo "gsd $GSD" | tee -a tmpNFT
echo "Q $Q" | tee -a tmpNFT
echo "pict $pict" | tee -a tmpNFT

echo "###################"
echo "##### STEP 1 skipping"
echo "###################"
################
# Run nftEval.sh to get the stats required
# this should be done before copying simple files
#nftEval.sh $id >> tmpNFT 
#sig=`tail -1 evalResults-$id | cut -c 37-43`
#avg=`tail -1 evalResults-$id | cut -c 23-30`




echo "###################"
echo "##### STEP 2 evalResultsX"
echo "###################"
rm -f CSPLOT.pgm
rm -f CSPLOT.TXT

landmarkEval.sh ${id}$code | tee evalResultsX >> tmpNFT

avg=`tail -1 evalResultsX | awk ' { print $4;}' `
sigX=`tail -1 evalResultsX | awk ' { print $6;}' `

#sigX=`tail -1 evalResultsX | cut -c 36-43`
#avg=`tail -1 evalResultsX | cut -c 22-30`
echo "sigX:  " $sigX
echo "avg:  " $avg
coord=`grep Lat tmpOut | head -1 | cut -c 19-35`
cardinalCS CSPLOT.TXT | tee -a tmpOut

/bin/cp -f tmpOut $path/$id/output.txt
echo ${id}$code | flatAlbedo > tmpOut
maxAlb=`grep Max tmpOut | awk ' { print $3; } ' `
stdAlb=`grep Std tmpOut | awk ' { print $3; } ' `
/bin/cp -f tmpOut $path/$id/albedo.txt



echo "###################"
echo "##### STEP 3 CSPLOT"
echo "###################"
################
################
# Copy simple files
/bin/cp CSPLOT.TXT $path/$id/CSPLOT.TXT
convert CSPLOT.ppm -resize 512x512 $path/$id/csplot.jpg
/bin/cp evalResultsX $path/$id/evalResults
/bin/cp -f notes $path/$id/notes

# Build SIGMAS
#score=`tail -2 SIGMAS.TXT | head -1 | cut -c 23-30`
#mScore=`echo "scale=2; $score * 1000 * 100" | bc | cut -c -4`
#convert SIGMAS.pgm   -resize 512x512 -fill white -gravity North -pointsize 15 -annotate +0+10 Max:${mScore}cm   $path/$id/sig.jpg


echo "###################"
echo "##### STEP 4 coverage" - Skipping
echo "###################"
# Build coverage
#echo XXXXXX > tmpRun
#echo 0 $GSD >> tmpRun
#map_coverage < tmpRun
#convert coverage_m.pgm -resize 512x512 $path/$id/post.jpg

#half=`echo $GSD / 2.0 + .000001 | bc -l`
#echo $half
#echo XXXXXX > tmpRun
#echo 0 $half >> tmpRun
#convert coverage_m.pgm -resize 512x512 $path/$id/postHigh.jpg

echo "###################"
echo "##### STEP 5 show/view map"
echo "###################"
# Show current map
echo ${id}$code | showmap 
convert ${id}$code.pgm -resize 512x512 $path/$id/curr.jpg
echo ${id}$code > tmpRun
echo 1 2 3 45 >> tmpRun
view_map_rgb < tmpRun
convert view.ppm -resize 512x512 $path/$id/rgb.jpg
echo ${id}$code | view_map_stereo
convert view.pgm -resize 512x512 $path/$id/stereo.jpg


cd MAPFILES
relink.sh ${id}$code.MAP XXXXXX.MAP
cd ..
echo XXXXXX | /opt/local/spc/bin/flatAlbedo >> nftNote
gnuplot /opt/local/spc/bin/albedo.gpi
/bin/cp -f out.png $path/$id/albedo.png

# Not using find_nofitT
#find_nofitT > $path/$id/fit.txt
#echo y | cp fit $path/$id/fit.txt

echo "###################"
echo "##### STEP 6 viewReg"
echo "###################"
# Run and copy the register view of the maplet
viewRegAll.sh ${id}$code
convert TEMPFILE.pgm $path/$id/reg.jpg


echo "###################"
echo "##### STEP 7 copy example landmark display######"
echo "###################"
# Copy landmark_display
convert LMRK_DISPLAY1.pgm $path/$id/dis.jpg

# Put the template in the id directory
/bin/cp /opt/local/spc/bin/mapletTemplate.html $path/$id/maplet.html

if [ -e MAPINFO.TXT ]
then
   lat=`grep  ${id}X MAPINFO.TXT | cut -c 23-31`
else
   lat=unk
fi

echo "###################"
echo "##### STEP 8 render images"
echo "###################"

nftImages $pict ${id}$code
/bin/mv -f $pict.jpg $path/$id/render.jpg

echo $pict > tmp
echo y >> tmp
echo 0 >> tmp
echo n >> tmp
echo n >> tmp
/opt/local/spc/unsup/unsup_v3_0_3D_2018_12_03/bin/Display < tmp
#/usr/local/bin/Display < tmp
convert -flip TEMPFILE.pgm $path/$id/source-full.png
cp -f /opt/local/spc/flightBennu/nftImg/$id.png $path/$id/source.png




echo "###################"
echo "##### STEP 9 Copy logs"
echo "###################"

#/bin/cp -vf log/${id}A/* $path/$id/
grep P6 LMKFILES/${id}$code.LMK | cut -c 1-12 > tmp
grep -f tmp PICINFO.TXT > $path/$id/imgInfo.txt

echo ${id}$code.LMK | cut -c 1-6 > tmp
stationEval.sh tmp
/bin/cp -vf eval/evalStation.txt $path/$id/landmarkStations.txt

#stationEvalupdate.sh tmp
stationEvalOsprey.sh tmp
/bin/cp -vf eval/evalStation.txt $path/$id/landmarkStationsUpdate.txt

echo "###################"
echo "##### STEP 10 Check on spikes"
echo "###################"

echo "i" > tmpRun
echo "${id}$code" >> tmpRun
echo "n" >> tmpRun
echo "n" >> tmpRun

echo "2" >> tmpRun
echo "8" >> tmpRun
echo "0" >> tmpRun
echo ".025" >> tmpRun
echo "5" >> tmpRun
echo "0" >> tmpRun
echo "q" >> tmpRun
LITHOS < tmpRun > tmpOut
#/opt/local/spc/unsup/test_v3_0_4B0_2020_02_03/bin/LITHOS < tmpRun > tmpOut
grep Correct tmpOut > $path/$id/correct.txt


################
# Make the link entry
# 	Making the link is default, unless you put an n at the end
newGSD=`echo "$GSD * 1000 * 100" | bc`
if [ "$2" != "n" ]
then
	echo "<tr><td><a href=/data$code/$id/maplet.html?id=$id>$id</a></td>   <td>$newGSD</td>    <td>$Q</td>   <td>$coord</td>     <td>$avg</td>   <td>$sigX</td>    <td>$maxAlb</td>    <td>$stdAlb</td>  <td> $d</td>    <td>$w</td></tr>" >> $path/mapletList.html
#else 
fi

echo "id: $id"
echo "sig: $sig"
echo "avg: $avg"
echo "sigX: $sigX"

echo "###################"
echo "#####  DONE  ######"
echo "###################"
