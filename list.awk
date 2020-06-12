BEGIN {
	start = 0;
	}

/BIGMAPS/ {
	start=0;
	}

//	{
	if ($1) 
		if (start) print $1;
}

/MAPLETS/	{
		start=1;
	}


