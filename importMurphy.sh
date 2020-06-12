# Eric E. Palmer - 14 Jan 2019
#    Takes a list of files and gets them ready for import

file=$1

if [ "$file" == "" ]
then
	echo "Error, no file selected"
	echo "Usage, $0 <file>"
	exit
fi

if [ ! -e $file ]
then
	echo "######## Error"
	echo "File $file is missing"
	exit
fi

if [  -e NEW_FILES/LMRKLIST.TXT ]
then
	echo "######## Error"
	echo "NEW_FILES/LMRKLIST.TXT exists already"
	echo "clean up NEW_FILES before you start"
	exit

fi

list=`cat $file`

for item in $list
do
	if [ "$item" == "END" ] 
	then
		break;
	fi

	echo Moving $item
	/bin/cp -f ../epMurphy/LMKFILES/$item.LMK NEW_FILES/LMKFILES/
	/bin/cp -f ../epMurphy/MAPFILES/$item.MAP NEW_FILES/MAPFILES/
	echo $item >> NEW_FILES/LMRKLIST.TXT
done

echo END >> NEW_FILES/LMRKLIST.TXT
