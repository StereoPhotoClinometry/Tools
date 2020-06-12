# Version 1.0 -- 1 Mar 2016, Eric E. Palmer
#########################
BEGIN		{	
	cnt = 0;
	overCnt = 0;
	imageCnt = 0;
	limbCnt = 0;
	name = 0;
	firstPass = 1;
	print "# Version 1.0, residualEval.awk"
	}
#########################
## New landmark found
$2 ~ /T/ {

	if (firstPass) {
		printf ("# %6s %13s %8s %8s %8s %8s %7s %10s\n", "Lmrk", "Img", 
					"dx", "dy", "pixSig", "sigma[m]", "#Img", "#Limb");
	}
					## skips firstPass time
	if (! firstPass) {
		#bigSum = 0
		#imgLimSum = 0;
		#printf ("  %8s ", name);
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
	val *= 1000;

	imgName = $1
	if ($1 == ">>") imgName = $2
	len=length (imgName)


	if ((len == 6) && (limbCnt==0)) {
		#overA [overCnt] = val;
		#print imgName, overCnt, "over", overA [overCnt];
		#overCnt++;
		limbReady =1;
	}

		## either a limb or image
	else if (len > 6) {
		if (limbReady){
			#limbA [limbCnt] = val;
			#print "limb", limbA [limbCnt];
			#limbCnt++;
		} else {
			if ($1 == ">>")  {
				cmnd = "grep " imgName " PICINFO.TXT | cut -c 57-75"
				printf ("%6s %13s %8s %8s %8s %8s", name, $2, $3, $4, $5, $6);
				system (cmnd);
			}
			#imageA [imageCnt] = val;
			#print imgName, imagrCnt, "imageA", imageA [imageCnt]
			#imageCnt++;
		}
	}

	item[cnt] = val;
	cnt++

	}
}

#########################
END {	
}



