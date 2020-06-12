# Eric E. Palmer - 25 Jan 2018
#	Cleans up a run so you can continue it (either for Graceful or crash)


list=`ls *.OOT`
mkdir -p tmpDir
rm -f run_scriptExtra.sh

for item in $list
do

d=`grep DONE $item`
root=`echo $item | cut -c 1-6`


if [ "$d" == "DONE" ]
then
	mv $root.INN tmpDir/
else
	echo -n $root
	echo "need"
	echo "LITHOSP < $root.INN | tee $root.OOT" >> run_scriptExtra.sh
fi

done

