# Eric E. Palmer - 25 Apr 2019
# 		This will run the command given a the 2nd argument for 
#				every item in the 3rd armguments file


cmd=$1
if [ "$cmd" == "" ]
then
	echo "Error.  No command given"
	echo "Usage: $0 <command> <file>"
	exit
fi

file=$2
if [ "$file" == "" ]
then
	echo "Error.  No command given"
	echo "Usage: $0 <command> <file>"
	exit
fi

if [ ! -e $file ]
then
	echo "Error.  File, $file, cannot be found"
	exit
fi


list=`cat $file`

# Do loop for the list
for item in $list
do
	# See if 1st char is a skipped char (tucked images)
	ch=`echo $item | cut -c 1`
	if [ "$ch" == "!" ]
	then
		echo "Skipping $item"
		continue
	fi
	if [ "$ch" == "#" ]
	then
		echo "Skipping $item"
		continue
	fi

	# End run if the keyword END is found
	if [ "$item" == "END" ]
	then
		echo "End found"
		exit
	fi

	$cmd $item | tee evalBig.txt

done
