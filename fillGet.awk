BEGIN { 
	start=0; 
	holdLine="unset";
	holdMin=9999;
	holdMap="unset";
	}

/input a 6-character/ { start=0; }
// {
	if (start) {
		if (($3 == 1.000) && (holdMin > $2)) {
			# print "Setting, ", $0
			holdMin=$2;
			holdLine = $0;
			holdMap = $1
		}#if $2
	}#if start
}#search

/List possibilities/ { start=1; }

END {
	print holdMap, "#", holdMin;
	}
