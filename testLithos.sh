# Eric E. Palmer - 3 Feb 2020
# Testing script for version 3.0.4B
# This will run the old version of LITHOS and the new one to seee
#		if the resulting maplets are the same

id=$1
base=/usr/local/bin/LITHOS
new=/Users/epalmer/lithos-3.0.4B0
new=/opt/local/spc/unsup/test_v3_0_4B0_2020_02_03/bin/LITHOS
new=v3.0.5B0/LITHOS

echo -n "Base version: " >> tmpOut
$base -v >> tmpOut
echo -n "New version: "  >> tmpOut
$new -v >> tmpOut

# ////////////////////////////
if [ "$id" == "" ]
then
	echo "Usage:  $0 <6char>"
	exit
fi


# ////////////////////////////
if [ ! -e "MAPFILES/$id.MAP" ]
then
	echo "Error:  MAPFILES/$id.MAP cannot be found"
	exit
fi

# Capture current state
/bin/cp MAPFILES/$id.MAP $id-start
/bin/cp LMKFILES/$id.LMK $id-start.LMK

# Reset the output file
out=results-$id
echo "Date:" `date` > $out
echo "i" > tmp
echo $id >> tmp
cat /opt/local/spc/bin/testScript.txt >> tmp


echo "####################################"
echo "Testing $id "
echo "####################################"

# Setup
echo "Running LITHOS, setting a baseline" | tee -a $out
echo "Path: $base" | tee -a $out
/bin/cp $id-start MAPFILES/$id.MAP
/bin/cp $id-start.LMK LMKFILES/$id.LMK

# Run
$base 1 < tmp >> $out
/bin/cp MAPFILES/$id.MAP $id.check

# Extra eval stats
echo $id | flatMap
mv $id.TXT results-topo1.txt
echo $id | flatAlbedo > $id.TXT
mv $id.TXT results-albedo1.txt
landmarkEval.sh $id | tee -a $out

echo "Running LITHOS with seed of 1 to ensure identifical results" | tee -a $out
# Setup
/bin/cp $id-start MAPFILES/$id.MAP 
/bin/cp $id-start.LMK LMKFILES/$id.LMK

# Run
$base 1 < tmp >>  $out
/bin/cp MAPFILES/$id.MAP $id.check2

# Eval required match
echo "Running diff for the same pair" | tee -a $out
echo -n "Testing: " | tee -a $out
diff $id.check $id.check2 | tee -a $out
echo "Done" | tee -a $out


############################3
# Set up
echo "####################################" | tee -a $out
echo "Running NEW with seed of 1 to ensure identifical results" | tee -a $out
echo "Path: $new" | tee -a $out
echo y | cp $id-start MAPFILES/$id.MAP | tee -a $out

# Run
$new 1 < tmp >> $out
/bin/cp MAPFILES/$id.MAP $id.check3
grep Correct $out 

# Get eval
echo $id | flatMap
mv $id.TXT results-topo3.txt
echo $id | flatAlbedo > $id.TXT
mv $id.TXT results-albedo3.txt
landmarkEval.sh $id | tee -a $out

echo "####################################" | tee -a $out
echo "####### Eval #######################" | tee -a $out
echo "####################################" | tee -a $out
echo "Running diff for change" | tee -a $out
echo -n "Testing: " | tee -a $out
diff -q $id.check $id.check3 | tee -a $out
echo "Done" | tee -a $out


echo "####################################" | tee -a $out
echo "Checking topo channel" | tee -a $out
echo -n "Testing: " | tee -a $out 
diff -q results-topo1.txt results-topo3.txt | tee -a $out
echo "Done" | tee -a $out

echo "####################################" | tee -a $out
echo "Checking albedo channel" | tee -a $out
echo -n "Testing: " | tee -a $out 
diff -q results-albedo1.txt results-albedo3.txt | tee -a $out
echo "Done" | tee -a $out


