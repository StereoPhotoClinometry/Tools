# Eric E. Palmer - 1 April 2019
# ParameterUpdate - sets a varierty of parameters to the user defined amount

file=$1

if [ "$file" == "" ]
then
	echo "No file listed"
	echo "Usage: $0 <file>"
fi

# Set up a backup directory
if [ ! -e SUMFILES ]
then
	echo "Error, not in SPC Dir"
	exit
fi

high=0
low=99999

#select ans in "low" "high"  "threshold" "quit"; do
select ans in "threshold" "quit"; do

case $ans in
	threshold)
		echo "Threshold"
		echo "What is the new low threshold?"
		read low
		echo "What is the new high threshold?"
		read high
		break
		;;
	low)
		echo "Low"
		echo "What is the new low threshold?"
		read low
		break
		;;
	high)
		echo "High"
		echo "What is the new high threshold?"
		read high
		break
		;;
	quit)
		echo "Nevermind"
		exit
		;;
	*)
		echo "I'm so confused"
		exit
		;;
esac
done




# Backup the files
mkdir -p SUMFILES/prev

list=`cat $file | cut -c 1-12`
list=`head -3 $file | cut -c 1-12`

# Do the whole loop

for item in $list
do
	if [ "$list" == "END" ]
	then
		echo "Exit due to END"
		exit
	fi

	# Copy old
	/bin/cp -fv 	SUMFILES/$item.SUM SUMFILES/prev/

	# Print top
	sed -n '1,2p' SUMFILES/$item.SUM > SUMFILES/out

	# Print line
	line=`cat SUMFILES/$item.SUM | sed '3q;d' `
	cat SUMFILES/$item.SUM | sed '3q;d' | cut -c 1-14 > pt1
	echo "$low $high  " > pt2
	cat SUMFILES/$item.SUM | sed '3q;d' | cut -c 27- > pt3
	paste -d \\ pt1 pt2 pt3 >> SUMFILES/out
	#echo $pt1 $low $high $pt2 >> SUMFILES/out

	# Print end
	sed -n '4,9999p' SUMFILES/$item.SUM >> SUMFILES/out





done

