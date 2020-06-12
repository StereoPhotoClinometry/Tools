# Eric E. Palmer - 23 Apr 2019
# Script to build ZMaps and copy useful data

list=`ls ZINPTS | cut -c 1-6`

sum=0
count=0
for item in $list
do
	echo $item
	echo $item > tmpRun
	cat ZINPTS/$item.IN >> tmpRun
	bigMapRef < tmpRun
	score=`tail -2 SIGMAS.TXT | head -1 | cut -c 23-30`
	mScore=`echo "scale=2; $score * 1000" | bc | cut -c -4`
	sum=`echo $sum + $mScore | bc`
	count=`echo $count + 1 | bc`
	echo $item | showmap
	convert $item.pgm ~/send/$item.jpg
	convert SIGMAS.pgm   -fill white -gravity North -pointsize 15 -annotate +0+10 Max:${mScore}m  ~/send/sig-$item.jpg
	rm $item.pgm
	rm SIGMAS.pgm
done

echo y | cp SIGMAS.TXT ~/send/
echo "scale=4; $sum / $count" 
avg=`echo "scale=4; $sum / $count" | bc`
echo "Avg $avg"

