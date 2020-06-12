BEGIN { first = 1; }
/Rad/ {
		if (first )
			rad1 = $5;
		else 
			rad2 = $5;
		first = 0
      lat = $3;
      lon = $4;
}

END { 
		delta = rad1 - rad2; 
		print lat, lon, rad1, rad2, delta
}

