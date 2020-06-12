# Eric E. Palmer - 26 Nov 201
# This takes the master directory on spc03 and 
#	creates a copy (slave) on whatever machine you are on
#	Note - be sure there is nothing you want to 
#	save on the slave machine

#mainDir=nft-master.v2C
mainDir=nft-master.v13


host=`hostname | cut -c 4-5`
p=`pwd`


if [ $p != "/Users/Shared/spc-work" ]
then
	echo "Wrong directory $p"
	exit
fi


name=slave-$host
echo "Name: $name"

echo $name

# Check to see if we will lose anything
if [ -e $name ]
then

	cat $name/config/nftID
	ls -lt $name/nftConfig/*.tar | head

	echo -n "Are you sure you want to continue [y]?"
	read ans
	echo $ans
	if [ "$ans" != "y" ]
	then
		echo "Stopping"
		exit
	fi
	echo "Continue"

fi

rsync -hapvP --exclude=log spc02:/Users/Shared/spc-work/$mainDir/ $name




