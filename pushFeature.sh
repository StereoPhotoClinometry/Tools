# Eric E. Palmer - 9 May 2019
# Puts things on the webserver so we can more easily see it.

id=$1

if [ "$id" == "" ]
then
	echo "Missing id"
	echo "Usage $0 <id> (n)"
	exit
fi

# Test to see if you are running on a Mac Server, or a normal mac.
path="/Library/Server/Web/Data/Sites/Default/data/"
if [ -e $path ];
then
   path="/Library/Server/Web/Data/Sites/Default/data/"
   #echo "  Machine:  Server "
else
   path="/Library/WebServer/Documents/data/"
   #echo "  Machine:  Local "
fi

# Test to see if the final path exists, error if it doesn't
if [ ! -e $path ];
then
   echo $path does not exit
   exit
fi
d=`date`


# Build the path to put files
mkdir -p $path/$id/




echo "###################"
echo "##### STEP 1 ######"
echo "###################"
################
# Run nftEval.sh to get the stats required
# this should be done before copying simple files
nftEval.sh $id
sig=`tail -1 evalResults-$id | cut -c 37-43`
avg=`tail -1 evalResults-$id | cut -c 23-30`


# Build SIGMAS
score=`tail -2 SIGMAS.TXT | head -1 | cut -c 23-30`
mScore=`echo "scale=2; $score * 100000" | bc | cut -c -4`
score=`tail -2 SIGMAS.TXT | head -1 | cut -c 47-`
aScore=`echo "scale=2; $score * 100000" | bc | cut -c -4`
convert SIGMAS.pgm   -resize 512x512 -fill white -gravity North -pointsize 15 -annotate +0+10 Max:${mScore}cm--Avg:${aScore}cm   $path/$id/sigBig.jpg


echo "###################"
echo "##### STEP 2 ######"
echo "###################"
landmarkEval.sh ${id}X | tee evalResultsX
sigX=`tail -1 evalResultsX | cut -c 37-43`




echo "###################"
echo "##### STEP 3 ######"
echo "###################"
################
################
# Copy simple files
/bin/cp CSPLOT.TXT $path/$id/CSPLOT.TXT
convert CSPLOT.ppm -resize 512x512 $path/$id/csplot.jpg
/bin/cp evalResults-$id $path/$id/evalResults
/bin/cp -f notes $path/$id/notes

# Build SIGMAS
bigMapRef < mapConfig/ROI-${id}V.in
score=`tail -2 SIGMAS.TXT | head -1 | cut -c 23-30`
mScore=`echo "scale=2; $score * 100000" | bc | cut -c -4`
score=`tail -2 SIGMAS.TXT | head -1 | cut -c 47-`
aScore=`echo "scale=2; $score * 100000" | bc | cut -c -4`
convert SIGMAS.pgm   -resize 512x512 -fill white -gravity North -pointsize 15 -annotate +0+10 Max:${mScore}cm--Avg:${aScore}cm   $path/$id/sig.jpg


grep ${id}W SIGMAS.TXT | grep -v "0.000  "  > tmpOut
gnuplot /opt/local/spc/bin/roiSigmas.gpi
/bin/cp roiSigmas.png $path/$id/


# Make the list of stations used 
getImagesInLandmarks2.sh USED_MAPS.TXT
/bin/cp tmpjrw $path/$id/stations.txt



echo "###################"
echo "##### STEP 4 ######"
echo "###################"
# Build coverage
echo XXXXXX > tmpRun
echo 0 .00014 >> tmpRun
map_coverage < tmpRun
convert coverage_m.pgm -resize 512x512 $path/$id/post.jpg





echo "###################"
echo "##### STEP 5 ######"
echo "###################"
# Show current map
echo XXXXXX | showmap 
convert XXXXXX.pgm -resize 512x512 $path/$id/curr.jpg
echo XXXXXX > tmpRun
echo 1 2 3 45 >> tmpRun
view_map_rgb < tmpRun
convert view.ppm -resize 512x512 $path/$id/rgb.jpg
echo XXXXXX | view_map_stereo
convert view.pgm -resize 512x512 $path/$id/stereo.jpg





# Not using find_nofitT
#find_nofitT > $path/$id/fit.txt
#echo y | cp fit $path/$id/fit.txt

echo "###################"
echo "##### STEP 6 ######"
echo "###################"
# Run and copy the register view of the maplet
if [ -e mapConfig/img-$id ]
then
	list=`cat mapConfig/img-$id | cut -c 1-12`
	first=`head mapConfig/img-$id | cut -c 1-12`
	cnt=0
	imgStr=""
	for item in $list 
	do
		cnt=`echo $cnt + 1 | bc`
		echo $item \($cnt\)
		viewReg2.sh $id $item
		convert TEMPFILE.pgm $path/$id/reg-$item.jpg
		imgStr="$imgStr <a href=/data/$id/reg-$item.jpg>$cnt</a> "
	done
	convert TEMPFILE.pgm $path/$id/reg.jpg
fi






echo "###################"
echo "##### STEP 7 ######"
echo "###################"
# Copy landmark_display
convert LMRK_DISPLAY1.pgm $path/$id/dis.jpg

# Put the template in the id directory
/bin/cp /opt/local/spc/bin/roiTemplate.html $path/$id/roi.html

if [ -e MAPINFO.TXT ]
then
   lat=`grep  ${id}X MAPINFO.TXT | cut -c 23-31`
else
   lat=unk
fi


################
# Make the link entry
# 	Making the link is default, unless you put an n at the end
if [ "$2" != "n" ]
then
	echo "<tr><td><a href=/data/$id/roi.html?id=$id>$id</a></td>   <td>$lat</td>    <td>$imgStr</td>   <td>$avg</td>   <td>$sigX</td>    <td> $d</td></tr>" >> $path/roi.html
fi

echo "###################"
echo "#####  DONE  ######"
echo "###################"
