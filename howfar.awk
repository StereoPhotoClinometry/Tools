BEGIN { max = 0 }
/\+/ {
	if ($1 > max) max = $1;
	distX [$2] += $3;
	distY [$2] += $4;
	listA [$1] = $2;
}
END {
	biggest=0;
	for (i=1; i<=max; i++) {
		nameStr =listA [i];
		#printf ("%s		%f		%f\n", nameStr, distX [nameStr], distY [nameStr]);
		if (biggest < distX [nameStr]) {
			biggest = distX[nameStr];
			biggestName = nameStr;
		}#if
		if (biggest < distY [nameStr]) {
			biggest = distY[nameStr];
			biggestName = nameStr;
		}#if
	}#for
	print biggestName, "  Biggest:  ", biggest;
}
