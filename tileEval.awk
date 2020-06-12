BEGIN {
	nofit = 0;
	nocorr = 0;
	str = "";
	done = 0;
	imgNr = 0;
	imageA [imgNr] = "null";
	removeStr = "";
	removedNr = 0;
	}
// { 
}

/enter spacing/ {			# resets each time we do a 1-0-1
	#print "restart";
	imgNr = 0;
	nofit = 0;
   str = "";
	nocorr = 0;
	}

/picnm/ {			# resets each time we do a 1-0-1
	imgNr = 0;
	#print "set img 0 - picnm"
	}

						# counts the image number that correlates
/\+/ {
	#print $0
	imgNr ++;
	}

/Current landmark/ {		# Reset strings for the final remvoed assignment
	if ($4 != "NONE")
		landmarkName = $4;
	}

/Comments/ {		# Reset strings for the final remvoed assignment
	removeStr = ""
	}
/removed/ {
	removeStr = removeStr "\n		Removed: " $1
	removedNr++;
	}

/Reset all/ {
	#print "Setting nofit to 0"
	nofit = 0;
}
						# How many overlaps don't fit
/No fit/ {
	#print "No fitting";
	nofit++;
	}

						# Flag for image that has no correlation
/0.0000    0.0000/ {
	nocorr++;
	str = str "\n		 (" $1 ") "  $2 
	}

						# The program finished and exited cleanly
/DONE/ {
	done = 1;
	}
	
						# Print out the values
END {
	printFlag = 0;
	if (nofit || nocorr || !done) printFlag = 1;
	if (imgNr <= 3) printFlag = 1;

	if (printFlag) printf ("	%s %s", landmarkName, id);

	if (imgNr <= 3) printf (" Img: %d (removed %d) ", imgNr, removedNr);
	if (nofit) printf ("  nofit: %d ", nofit);
	if (nocorr) printf ("  NOCORR: %d %s", nocorr, str);
	#if (removeStr) print removeStr;
	if (printFlag) printf ("\n");
	#if (!done) printf ("	Running ")
	}

