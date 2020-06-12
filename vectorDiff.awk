BEGIN {	record=0; }

/CX/	{ cx1 [record] = $1; cx2 [record] = $2; cx3 [record] = $3; }
/CY/	{ cy1 [record] = $1; cy2 [record] = $2; cy3 [record] = $3; }
/CZ/	{ cz1 [record] = $1; cz2 [record] = $2; cz3 [record] = $3; }
/SIGMA_VSO/	{ sv1 [record] = $1; sv2 [record] = $2; sv3 [record] = $3; }
/SIGMA_PTG/	{ sp1 [record] = $1; sp2 [record] = $2; sp3 [record] = $3; }
/SCOBJ/	{ scobj1 [record] = $1; scobj2 [record] = $2; scobj3 [record] = $3; }

/FILE/	{ 
	record++; 
}

END {
		if (cx1[0] == 0) print "Fail cx1";
		if (cy1[0] == 0) print "Fail cy1";
		if (cz1[0] == 0) print "Fail cz1";

	del= (scobj1[0]-scobj1[1])**2 +(scobj2[0]-scobj2[1])**2 +(scobj3[0]-scobj3[1])**2 ;
	#print "Delta shift between NOM and SUM";
	printf ("%3.3f [m] SCOBJ %s\n", sqrt (del)*1000, name);

	del1=(cx1[0]-cx1[1])**2 + (cx2[0]-cx2[1])**2 + (cx3[0]-cx3[1])**2;
	printf ("CX %3.3e  (%3.5f)\n", sqrt (del1), cx1[1]);

	del2=(cy1[0]-cy1[1])**2 + (cy2[0]-cy2[1])**2 + (cy3[0]-cy3[1])**2;
	printf ("CY %3.3e  (%3.5f)\n", sqrt (del2), cy1[1]);

	del3=(cz1[0]-cz1[1])**2 + (cz2[0]-cz2[1])**2 + (cz3[0]-cz3[1])**2;
	printf ("CZ %3.3e  (%3.5f)\n", sqrt (del3), cz1[1]);

	printf ("%3.3e	%3.3e	%3.3e\n", sqrt(del1), sqrt(del2), sqrt(del3));

	del=sv1[1]**2 + sv2[1]**2 + sv3[1]**2;
	printf ("Sigma VSO %3.3f m \n", sqrt (del)*1000);

	del=sp1[1]**2 + sp2[1]**2 + sp3[1]**2;
	printf ("Sigma PTG %3.3f mrad \n", sqrt (del)*1000);

}
