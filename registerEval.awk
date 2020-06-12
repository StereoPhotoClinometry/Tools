BEGIN {
	flag = 0;
	dx = 0;
	dy = 0;
	corr = 0;
	}
// { 
	if (flag) {
		#print "		" $0
		dx += abs ($1);
		dy += abs ($2);
		corr = $3;
	
		flag = 0;
	}#if flag
}
/No correlation/ {
	corr = "-1		NoCorr";
	exit;
	}
/Autocorrelate/ {
		flag = 1;
	} # if match

END {
	print "	", dx + dy, corr;
	}

