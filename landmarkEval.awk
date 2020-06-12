BEGIN {
	ready = 0;
	min=1
	max=0
	}
//  { 
		if (ready) {
		val[count] = $5;
		count++;
		sum += $5
		}
	}
/new spacing/ { 
	ready=0;
}
/enter spacing/ { 
	ready=1;
	sum = 0;
	count = 0; 
}
END {
	#print "# min	max	avg	stdev	sigmaScore"
	count -= 4
	if (count)
		avg = sum/count;
	else
		print "Count is zero"

	#print "Avg: ", avg

	for (i=1 ;i<=count; i++) {
		delta += (val[i] - avg)**2;
		if (val[i] < min) min = val[i]
		if (val[i] > max) max = val[i]
	}#for
	#print "SumDelta: ", delta
	stdev = sqrt (delta/(count-1))
	sigma = (avg - 0.6) / stdev
	printf ("%3.4f	%3.4f	%3.4f	%3.4f	%3.4f\n", min, max, avg, stdev, sigma)

}
