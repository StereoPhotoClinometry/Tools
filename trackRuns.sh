# Eric E. Palmer - 17 Jan 2015

# Checks to see if lithos is running, notifies me when it is done


# if [ -z $value ] 

if [ -e tmpCount ]; then
	cnt=`cat tmpCount`
else
	cnt=100
fi
cnt=`echo $cnt + 1 | bc`

echo "##################################" >> run.log
echo "# `date`" >> run.log
echo "# Logging starting at cnt $cnt" >> run.log


select answer in "email" "loop" "geometry-loop"; do
	case $answer in
	email )
		echo "Email only"
		break;;
	loop )
		echo "Loop"
		break;;
	geometry-loop )
		echo "Loop with geometry"
		break;;
	esac
done

start=`ls *INN | wc -l`

while [ 1 ]
do
	numJobs=`ps -u epalmer | grep LITHOSP | grep -v grep | wc -l`
	echo "Num Jobs:  $numJobs"
	no=`ls *OOT | wc -l`
	echo "$no of $start have finished"

	if [ $numJobs -eq 0 ]; then
		echo "Done"
		d=`date`
		echo "# Run $cnt done at $d" >> run.log
		echo "Run $cnt is done - $d" | mail -s "lithos run $cnt" epalmer@psi.edu

		# Update the counter for tracking which run
		echo $cnt > tmpCount

		# Email then end 
		if [ $answer = "email" ]; then
			break;
		fi


		/opt/local/spc/bin/buildShape512.sh truth-$cnt-A

		# Run geometry
		if [ $answer = "geometry-loop" ]; then
			echo "# Running geometry" >> run.log
			echo "Run geometry"
			echo "120" > tmpRun
			echo "30" >> tmpRun
			echo "y" >> tmpRun
			echo "n" >> tmpRun
			geometry < tmpRun
		fi

		/opt/local/spc/bin/buildShape512.sh truth-$cnt-B

		# Diagonistics 
		mkdir out-$cnt
		date > list-$cnt
		find_nofitP >> list-$cnt
		issues=`wc -l list-$cnt`
		redo=`wc -l redo.txt`
		echo "# Issues $issues $redo" >> run.log

		resVal="3 .005 .005"
		echo "# Running residuals using $resVal" >> run.log
		echo $resVal | residuals
		grep RMS RESIDUALS.TXT >> run.log
		res=`grep ">" RESIDUALS.TXT | wc -l`
		echo "Residual flags:  $val" >> run.log
		map=`grep ">" MAPINFO.TXT | wc -l`
		echo "Map flags:  $val" >> run.log
		pic=`grep ">" PICINFO.TXT | wc -l`
		echo "Pic flags:  $val" >> run.log
		echo "# Issues	ResFlag MapFlag PicFlag" >> run.log
		echo $issues	$res	$map	$pic >> run.log

		# Move files
		mv *OOT out-$cnt
		gzip out-$cnt/*

      grep SCOBJ SUMFILES/* > out-$cnt/scobj.txt
		mv list-$cnt out-$cnt
		cp RESIDUALS.TXT out-$cnt
		cp PICINFO.TXT out-$cnt
		cp MAPINFO.TXT out-$cnt
		cp redo.txt out-$cnt
#		rsync -hapv out-$cnt ormacsrv1.lpl.arizona.edu:/Volumes/Share/epalmer/back

		# Start the run
		echo "##################################" >> run.log
		cnt=`echo $cnt + 1 | bc`
		echo "# Starting run $cnt" >> run.log
		date >> run.log
		sh run.sh
	fi

sleep 60

done
