# Eric E. Palmer - 17 Jan 2015
# Checks to see if lithos is running, notifies me when it is done
vers=1.1

if [ -e config/iterationCount ]; then
	cnt=`cat config/iterationCount`
else
	mkdir -p config
	cnt=1000
fi
cnt=`echo $cnt + 1 | bc`
userid=`whoami`

mkdir -p log/
echo "##################################" >> log/monitord.log
echo "# `date`" >> log/monitord.log
echo "# Logging starting at cnt $cnt" >> log/monitord.log


start=`ls *INN | wc -l`
echo "Working on iteration:  $cnt"

while [ 1 ]
do
	numJobs=`ps -u $userid | grep LITHOSP | grep -v grep | wc -l`
	echo "Num Jobs:  $numJobs"
	no=`ls *OOT | wc -l`
	echo "$no of $start have finished"

	########### End of Iteration ############
	if [ $numJobs -eq 0 ]; then
		echo "Done"
		d=`date`
		echo "# Run $cnt done at $d" >> log/monitord.log

		# Update the counter for tracking which run
		echo $cnt > config/iterationCount

		doFind=`grep find config.txt | awk ' { print $2;}'`
		doGeo=`grep geometry config.txt | awk ' { print $2;}'`
		doRes=`grep residuals config.txt | awk ' { print $2;}'`
		doLocal=`grep localloop config.txt | awk ' { print $2;}'`
		doEmail=`grep email config.txt | awk ' { print $2;}'`

		doTerm=`grep terminate config.txt | awk ' { print $2;}'`
		doMax=`grep maximum config.txt | awk ' { print $2;}'`


		# Diagonistics 
		mkdir -p log/out-$cnt
		date > list-$cnt
		/opt/local/spc/bin/iterateEval.sh

		######################
		if [ "$doFind" == "1" ]
		then
			echo "Do Find"
			find_nofitP >> list-$cnt
			issues=`wc -l list-$cnt`
			redo=`wc -l redo.txt`
			echo "# Issues $issues $redo" >> log/monitord.log
			/bin/cp redo.txt log/out-$cnt
		fi

		######################
		if [ "$doGeo" == "1" ]
		then
			echo "Do Geo 1"
         echo "# Running geometry" | tee -a log/monitord.log
         echo "120" > tmpRun-$cnt
         echo "10" >> tmpRun-$cnt
         echo "y" >> tmpRun-$cnt
         echo "n" >> tmpRun-$cnt
         geometry < tmpRun-$cnt
      fi


		######################
		if [ "$doGeo" == "2" ]
		then
			echo "Do Geo 2"
         echo "# Running geometry" | tee -a log/monitord.log
         echo "20" > tmpRun-$cnt
         echo "10" >> tmpRun-$cnt
         echo "y" >> tmpRun-$cnt
         echo "n" >> tmpRun-$cnt
         geometry < tmpRun-$cnt
		fi


		######################
		if [ "$doRes" == "1" ]
		then
			echo "Do Residuals"
			resVal="3 .005 .005"
			echo "# Running residuals using $resVal" >> log/monitord.log
			echo $resVal | residuals
			grep RMS RESIDUALS.TXT >> log/monitord.log
			res=`grep ">" RESIDUALS.TXT | wc -l`
			echo "Residual flags:  $val" >> log/monitord.log
			map=`grep ">" MAPINFO.TXT | wc -l`
			echo "Map flags:  $val" >> log/monitord.log
			pic=`grep ">" PICINFO.TXT | wc -l`
			echo "Pic flags:  $val" >> log/monitord.log
			echo "# Issues	ResFlag MapFlag PicFlag" >> log/monitord.log
			echo $issues	$res	$map	$pic >> log/monitord.log
			/bin/cp RESIDUALS.TXT log/out-$cnt
			/bin/cp PICINFO.TXT log/out-$cnt
			/bin/cp MAPINFO.TXT log/out-$cnt
		fi

		######################
		# Run local loop
		if [ "$doLocal" == "1" ]
		then
			echo "Do Local"
			if [ -e localLoop.sh ]; then
				sh localLoop.sh $cnt >> log/monitord.log
			fi
		fi

		######################
		# Send an email
		if [ "$doEmail" == "1" ]
		then
			echo "Do Email"
			echo "Run $cnt is done - $d" | mail -s "lithos run $cnt" $userid@psi.edu
		fi

		######################
		# Move files
		/bin/mv -f *OOT log/out-$cnt
		/bin/mv -f list-$cnt log/out-$cnt
      grep SCOBJ SUMFILES/* > log/out-$cnt/scobj.txt
		gzip log/out-$cnt/*

		######################
		# Terminate the deamon.  Just let it die and it won't restart run.sh
		if [ "$doTerm" == "1" ]
		then
			echo "Do Term"
			exit
		fi

		######################
		# not used - checks to see if it should end after a number of iterations
		if [ "$doMax" <  "$cnt" ]
		then
			echo "Do Max"
			exit
		fi

		######################
		# Start the run
		echo "##################################" >> log/monitord.log
		cnt=`echo $cnt + 1 | bc`
		echo "# Starting run $cnt" >> log/monitord.log
		date >> log/monitord.log
		sh run.sh
	fi		# if for end of iteration

sleep 60

done		# big while loop
