BEGIN {
	count=0;
	}

// { 
	#print ">>>"$1"<<<<" count;
	if ($1 == "") {
		if (count >= 3) {
			for (i=0; i<count; i++){
				if (imgLonA[i] < 90) low=1;
				if (imgLonA[i] > 270) hi=1;
			}
			if (hi) low=0;
			if (hi) print "#hi"
			if (low) print "#low"
			for (i=0; i<count; i++){
				if (hi) 
					if (imgLonA[i] < 120) { imgLonA[i] += 360;}
				if (low)
					if (imgLonA[i] > 240) { imgLonA[i] -= 360;}
				print imgLatA[i], imgLonA [i], imgRA[i]
				}
			print imgLatA[0], imgLonA [0], imgRA[0]
			print ""
		}
		#else print "skipping: " count
		count = 0;
	}
	else {
		hi=0;
		low=0;
		imgLatA [count] = $1
		imgLonA [count] = $2
		imgRA [count] = $3
		count++
	}
}

