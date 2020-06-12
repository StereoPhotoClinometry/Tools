# Version 1.0 -- 1 March 2016, Eric E. Palmer
#########################
BEGIN		{	
	cnt = 0;
	overCnt = 0;
	imageCnt = 0;
	limbCnt = 0;
	name = 0;
	firstPass = 1;
	totalSum = 0;
	totalCnt = 0;
	}
#########################
## New landmark found
$2 ~ /T/ {

	res = $3;
	if (firstPass) {
		printf ("  %8s %8s %8s %8s %8s   [m] %8s\n", "Name", "Image", "Limbs", "Over", "ImgLimb", "res[m]");
	}

					## skips firstPass time
	if (! firstPass) {
		#print imageCnt, overCnt, limbCnt
		bigSum = 0
		imgLimSum = 0;
		printf ("  %8s ", name);

		if (imageCnt) {
			sum = 0;
			for (i=0; i<imageCnt; i++) {
				sum += imageA [i] * imageA [i]
				bigSum += imageA [i] * imageA [i]
				imgLimSum += imageA [i] * imageA [i]
			} #for
			imgVal = sqrt (sum/imageCnt);
			printf ("%8.5f ", imgVal);
		} else printf ("%8s ", "-");

		if (limbCnt) {
			sum = 0;
			for (i=0; i<limbCnt; i++) {
				sum += limbA [i] * limbA [i]
				bigSum += limbA [i] * limbA [i]
				imgLimSum += limbA [i] * limbA [i]
			} #for
			limbVal = sqrt (sum/limbCnt);
			printf ("%8.5f ", limbVal);
		} else printf ("%8s ", "-");

		if (overCnt) {
			sum = 0;
			for (i=0; i<overCnt; i++) {
				sum += overA [i] * overA [i]
				bigSum += overA [i] * overA [i]
			} #for
			overVal = sqrt (sum/overCnt);
			printf ("%8.5f ", overVal);
		} else printf ("%8s ", "-");

		if (imageCnt + limbCnt)  {
			printf ("%8.5f ",  sqrt(imgLimSum/(imageCnt+limbCnt)));
			totalSum += sqrt(imgLimSum/(imageCnt+limbCnt));
			totalCnt++;
		}

		if (imageCnt + limbCnt + overCnt) 
			val = sqrt(bigSum/(imageCnt+limbCnt+overCnt));
		printf( "  all: %8.5f ",  val);
		printf( "  Res:%s\n",  res);
		

		name = 0;
	} 

	name = $1;
	cnt = 0;
	overCnt = 0;
	imageCnt = 0;
	limbCnt = 0;
	limbReady = 0;
	firstPass = 0;
}
#########################
$1 !~ /\.\.\./	{ 
	if ($2 != "T") {

	val = $5
	if ($1 == ">>") val = $6
	#val *= 1000;

	str = $1
	if ($1 == ">>") str = $2
	len=length (str)

	if ((len == 6) && (limbCnt==0)) {
		overA [overCnt] = val;
		#print str, overCnt, "over", overA [overCnt];
		overCnt++;
		limbReady =1;
	}

		## either a limb or image
	else if (len > 6) {
		if (limbReady){
			limbA [limbCnt] = val;
			#print "limb", limbA [limbCnt];
			limbCnt++;
		} else {
			imageA [imageCnt] = val;
			#print str, imagrCnt, "imageA", imageA [imageCnt]
			imageCnt++;
		}
	}

	item[cnt] = val;
	cnt++

	}
}

#########################
END {	
	print "# Average of img and limb:", totalSum/totalCnt;
}



