BEGIN {
	ready = 0;
	min=1
	max=0
	space = 0;
	happy = 0
	}
//  { 
		if (ready) {
		#if ( ! $1) print "blank"
		if ( ! $1) space++
		else {

			if (space == 2) {
			#print "-", $0
			val[count] = $5;
			count++;
			sum += $5
			if ($5 >= 0.6) happy++
			}
	
			if (space == 3) ready = 0
		} # else

		} # if ready
	} # search
/new spacing/ { 
	ready=0;
}
/picnm/ { 
	ready=1;
	sum = 0;
	count = 0; 
}
END {
	#print "# 	min	max	avg	stdev	sigmaScore pass"
	count -= 1
	if (count <= 0) count = 1
	avg = sum/count;
	#print "count: ", count
	#print "Avg: ", avg

	for (i=0 ;i<count; i++) {
		delta += (val[i] - avg)**2;
		if (val[i] < min) min = val[i]
		if (val[i] > max) max = val[i]
		#print i, val[i]
	}#for
	#print "SumDelta: ", delta
	if (count > 1) {
		stdev = sqrt (delta/(count-1))
		fracPass = happy / count * 100
	} else 
		stdev=0
	if (stdev)
		sigma = (avg - 0.6) / stdev
	else
		simga=0

	printf ("%3.4f	%3.4f	%3.4f	%3.4f	%3.2f	%3.2f\n", min, max, avg, stdev, sigma, fracPass)

}
