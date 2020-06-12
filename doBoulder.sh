# Eric E. Palmer - 11 Jan 2019
# Takes an argument of base boulder ID and 
#		runs the boulder fill

id=$1
root=${id}A


if [ "$1" == "" ] 
then
	echo "######## No argument given"
	echo "usage: $0 <id>"
	exit
fi

ID=$root
murphy
echo "Propagating the boulder: $ID" | tee -a notes


echo "Filling"
cd MAPFILES
relink.sh $ID.MAP XXXXXX.MAP | tee -a notes
cd ..
duplicates
relink.sh support/Ffill-Shape.seed make_scriptF.seed | tee -a notes
make_scriptF

sh run_script.b

echo "Iterating"
  relink.sh scripts/Piterate1ShSt.seed make_scriptP.seed 
  ls -l make_scriptP.seed >> notes
  MAKE_LMRKLISTX 
  duplicates 
  make_scriptP | tee run.sh
  ls -l make_scriptP.seed | tee -a notes
  echo "Running iteration at " `date` >> notes
  sh run.sh


