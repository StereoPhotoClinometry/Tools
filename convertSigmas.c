// convertSigmas
// Eric E. Palmer - 2015 or earlier
// Takes Bob SIGMA.TXT file from when the shape model is built
//		and puts it into lat/lon format

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

float version=1.0;

int main (int argc, char *argv[])
{
	char *str = "SIGMA.TXT";
	FILE *in;
	if (argc == 2) str = argv [1];

	in = fopen (str, "r");
	if (! in) {
		printf ("Couldn't open %s\n", str);
		fprintf (stderr, "Couldn't open %s\n", str);
		exit (-1);
	}

	int num;
	fscanf (in, "%d\n", &num);
	printf ("# num: %d\n", num);

	int i;
	long max = num*num*num;
max = 99847;
	fprintf (stderr, "max %ld\n", max);
	float maxVal, maxLat, maxLon;
	maxVal = 0;

	FILE *out = fopen ("latSigma.txt", "w");
	
	for (i=0; i<max; i++) {
		float x, y, z, sig;
		float	lat, lon, r;

		fscanf (in, "%f %f %f %f\n", &x, &y, &z, &sig);
		x *= 1000;		// convert to meters
		y *= 1000;		// convert to meters
		z *= 1000;		// convert to meters
		r = sqrt (x*x + y*y + z*z);
		lat =acos (z/r);
		lon = atan2 (y,x);
		lat *= 180/3.1415;
		lat = 90 - lat;
		lon *= 180/3.1415;
		if (lon < 0) lon += 360;
		lon = 360 - lon;		// Switching to W Lon

		if (sig > maxVal) {
			maxVal = sig;
			maxLat = lat;
			maxLon = lon;
		}// 

		fprintf (out, "%3.5f	%3.5f	%3.5f	%3.9f\n", lat, lon, r, sig);
	//break;
	}
	printf ("# %3.5f	%3.5f	%3.9f\n", maxLat, maxLon, maxVal);
	fprintf (out, "# %3.5f	%3.5f	%3.9f\n", maxLat, maxLon, maxVal);


}//main
