# this works for lithos version 2.1A7

function abs(var) {
	ret = var;
	if (ret < 0) ret *= -1;
	return (ret);
}

BEGIN {
		start = 0;
		count = 0;
		num_not=0;
		iterate=0;
		auto=0;
		numPicts= 0;
		printf ("#Landmk	Rez	MinCorr	MinPlus\n");
		minPlus="?????????";
	}

/Current landmark/ { 
		if ($4 != "NONE" ) {
			landmark = $4;
			start++;
		}
		if (first) first = 0;
}

/SCALE =/ {
		scale=$3;
}

/Lat\/Lon/ { 
		lat=$3; 
		lon=$4;
}

#/k    chi    lambda   phi     res/ {
/lambda/ {
		#print "--I'm in iterate";
		iterate=1;
		num_not=0;
}

/Picture to / {
		#print "--Num not used in tempate", num_not;
		count = 0;
		iterate=0;
		auto=0;
		numPicts= 0;
}

/new spacing/		{
	#print "-- Done with auto"
		numPicts = auto-1;
		numPlus = minPlus;
		auto = 0;		# stop this work
		minPlus="?????????";

}

//	{
		if (iterate) iterate++;
		if (auto) {
			if (length($0) < 40) {		# string is shorter, done with pict
				#print "--skip"
			}
			else { 					# found a pict
				if (minCorr > $5) { minCorr = $5;}
				if (length ($6) < length (minPlus) ) { minPlus = $6;}
				auto++;
			}
			dx = $3;
			dy = $4;
			holdShift = abs(maxDx);
			if (holdShift < abs(dx)) maxDx = dx;
			if (holdShift < abs(dy)) maxDx = dy;
			#print $0, minCorr, $6
		} #ifauto
	}

/\*/	{
		# Counts the number of images not used in the template
		if (iterate) num_not++;
	}

/enter spacing/ {
		# Used for the end of autocorrelate images
		#print "--Enter Spacing";
		auto=1;
		minCorr=1;
		minPlus="?????????";
		if (! firstDone) {
			firstDone=1;		#it's not really done, but we are processing
		}
		maxDx = 0;
	}

/Check for more images/ { 
	if (start) {
		printf ("%s	%f	", landmark, scale*1000);
		printf ("%f	%s	", minCorr, numPlus);
		if (abs(maxDx) < 1)  maxDx = "";		// skip
		printf ("%s	", maxDx);
		if (num_not) printf ("(stars %d) ", num_not);
	#	printf ("       Lat/Lon: %s %s\n", lat, lon);
	#	if (num_not) printf ("       Num pict: %d (stars %d) \n", numPicts, num_not);
		printf ("\n");
		firstDone = 0;
	}
}

END { 
	}
