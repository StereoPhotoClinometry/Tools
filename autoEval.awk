# Eric E. Palmer - 2 Feb 2018
# Parses the AUTOREGISTER log to see improvement or issues

##################################
BEGIN {
	try = 0;			# flag for counting -- needs better name
	start = 0;		# start of adding new images
	end = 0;			# end of adding new images
	delNum =0;
	none=""
	}

##################################
# Set the flag - track images started with
#		At the begining of the OOT file,
#		This happens after the original images
#		are displayed, but before the new ones
#		are added
/input 12-character/ {
	start = 1;
	tmpNum = 0;
}


################################## #
# 	Stops adding the number of existing images
/TEMPFILE.pgm/ {
	start = 0;
	startNum = tmpNum;  # if loop flag is found, save val
}

################################## #
# 	Stops adding the number of existing images
#		Used in autoregisterP
/REFLECT/ {
	start = 0;
	startNum = tmpNum;  # if loop flag is found, save val
}

##################################
# Set the flag - track images added
/Reject/ {
	try = 1;
	tryNum = 0;
}


##################################
# 	Denotes the main menu
/MAIN MENU/ {
	try = 0;
}

##################################
# Set the flag to count ending images
#		The last item in the main menu
/Change repredict/ {
	end = 1;
	tmpNum = 0;	## This will run a lot, so it must be reset
}

##################################
# Checks to see if the script has gotten
#		to the last step (b, 4).  Note the 
# 		last image number for the total of images
/Input number to change/ {
	end = 0;
	endNum = tmpNum;	# If the end flag is found, save the val
}

##################################
# Look at each line and react
// { 
	if (start) 		# Count num of lines until TEMPFILE.pgm
		tmpNum++;
	if (try) 		# Count num of lines until MAINMENU
		tryNum++;
	if (end) 		# Count num of lines until done with set-flag
		tmpNum++;

} # if match

##################################
# Very bad -- no landmarks
/No landmarks/ {
	none= "no landmarks";
	endNum = 0;
}

##################################
# How many thrown out
/removed/ {
	delNum ++;
}
	

END {
	startNum -=2;
	endNum -=3;
	#print ":  ", startNum, delNum, endNum, none
	status="";

	percent = delNum/endNum*100;
	if (percent > 10) status = "+";
	if (percent > 25) status = "#";
	if (percent > 50) status = "##";
	if (percent > 75) status = "###";

	if (none) 
		if (delNum > 6) status = "#####";

	if (endNum == -3) endNum = "0";

	printf (":  %d	%d (%d) %s %s\n", startNum, endNum, delNum, none, status);
	#printf (": %d / %d (%d)\n", endNum, endNum - startNum, delNum);
	}

