BEGIN {
		count = 0;
		num_not=0;
		iterate=0;
		auto=0;
		numPicts= 0;
		printf ("#Lat	Lon	height Landmark\n");
		minPlus="?????????";
	}

/Current landmark/ { 
		if ($4 != "NONE" ) landmark = $4;
		if (first) first = 0;
		}

/scale =/ {
		scale=$3;
		}

/Lat\/Lon/ { 
		lat=$3; 
		lon=$4;
		height=$5;
		}

/k    chi    lambda   phi     res/ {
		#print "I'm in iterate";
		iterate=1;
		num_not=0;
		}

/Picture to change/ {
		#print "Num not used in tempate", num_not;
		count = 0;
		iterate=0;
		auto=0;
		numPicts= 0;
		}


//	{
		if (iterate) iterate++;
		if (auto) {
			if (length($0) < 30) {		# string is shorter, done with pict
				numPicts = auto-1;
				numPlus = minPlus;
				auto = 0;		# stop this work
				minPlus="?????????";
			}
			else { 					# found a pict
				if (minCorr > $5) { minCorr = $5;}
				if (length ($6) < length (minPlus) ) { minPlus = $6;}
				auto++;
			}
			dx = $3;
			dy = $4;
			if (maxDx < dx) maxDx = dx;
			if (maxDx < dy) maxDx = dy;
		}
	}

/\*/	{
		# Counts the number of images not used in the template
		if (iterate) num_not++;
	}

/enter spacing/ {
		# Used for the end of autocorrelate images
		auto=1;
		minCorr=1;
		minPlus="?????????";
		if (! firstDone) {
			firstDone=1;		#it's not really done, but we are processing
		}
		maxDx = 0;
	}

/Check for more images/ { 
	printf ("%s	%s	%s	", lat, lon, height);
	printf ("%s	", landmark);
	printf ("\n");
	firstDone = 0;
	}

END { 
	}
