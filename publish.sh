# Builds a certificaiton and rsyncs a directory for customers
# 14 June 2017 - Eric E. Palmer
# Version 1.0 -- 
# 	Requires only using Bennu
#	Pass in the containing directory, which we use as the discriminator

dir=$1
host='ormacsrv1.lpl.arizona.edu'

# Validate the path
if [ "$dir" == "" ]
then
	echo "Directory is null";
	echo "Be in the root directory.  Give only the working directory"
	exit;
fi


# Check to see if it is a valid SPC working dir
if [ -e $dir/INIT_LITHOS.TXT ]
then
	echo "$dir Validates"
	echo
else
	echo "Cannot locate a SPC working directory"
	echo "Usage: $0 <dir>"
	echo "	<dir> must be the one you want to copy"
	echo "Be in the root directory.  Give only the working directory"
	exit
fi


echo "###############################################"
echo "############# Diagnostics #####################"
echo "###############################################"
ls -l $dir/SHAPEFILES/SHAPE.TXT
echo "###############################################"
echo $dir/SHAPEFILES/SHAPE.TXT | shape_info
echo "###############################################"
grep -i tpc $dir/INIT_LITHOS.TXT $dir/make_sumfiles.txt
echo "###############################################"
echo "###############################################"

# Begin making the certification document
if [ -a cert.txt ]
then
	rm cert.txt
fi

echo "Shape Model Version Certification" > cert.txt
date=`date`
echo "	Date Published:  $date" >> cert.txt

whoami=`whoami`
echo "	Published by:  $shoami" >> cert.txt

str=`hostname`
echo "	Machine generated:  $str" >> cert.txt

randKey=`echo $RANDOM`
echo "	Random Identificaiton Key:  $randKey" >> cert.txt

echo "Where do you want to archive the data?" 
select ans in "spc_distro" "spc_eval" "test" "other"; do
	case $ans in
	"spc_distro")
		echo "	#### spc_distro"
		workingPath="/archive/spc_distro/"
		cmnd="rsync -hapv --exclude=IMAGEFILES $dir $host:$workingPath/"
	break;;
	"spc_eval")
		echo "	#### spc_eval"
		workingPath="/archive/spc_eval/"
		cmnd="rsync -hapv --exclude=IMAGEFILES $dir $host:$workingPath/"
	break;;
	"test")
		echo "	#### test"
		workingPath="/SPC_Test/test-$randKey"
		cmnd="rsync -hapv --exclude=IMAGEFILES $dir $host:$workingPath/"
	break;;
	"other")
		echo "	#### other"
		echo "What is the new directory within spc-test?: "
		read newDir
		workingPath="/SPC_Test/$newDir-$randKey"
		cmnd="rsync -hapv --exclude=IMAGEFILES $dir $host:$workingPath/"
	break;;
	*) echo "invalid option - aborting"
		exit
	break;;
	esac
done

echo >> cert.txt
echo "What is the Version/Name of this model"
read name
echo "Version:  $name" >> cert.txt

# Build the data set, both entry and automated
echo >> cert.txt
echo "Which data set"
read data
echo "Data Used" >> cert.txt
echo "	$data" >> cert.txt

str=`pwd`
echo "	$str" >> cert.txt
echo "	$dir" >> cert.txt

echo "State of the model?" 
select yn in "final" "draft" "testing" "uncertified" "other"; do
	case $yn in
	"final")
	break;;
	"draft")
	break;;
	"testing")
	break;;
	"uncertified")
	break;;
	"other")
	break;;
	*) echo "invalid option - aborting"
		exit
	break;;
	esac
done

echo >> cert.txt
echo "Data Quality/State" >> cert.txt
echo "	$yn" >> cert.txt

echo >> cert.txt

echo "rsync command" >> cert.txt
echo $cmnd >> cert.txt

# Create and transfer the published time and cert file, clean up
echo "$randKey	$whoami	$date" > publishedDate.txt
$cmnd

# Just incase the source directory is locked down, open it up
chmod -R u+w $workingPath/Bennu
rsync publishedDate.txt $host:$workingPath/Bennu
rsync cert.txt $host:$workingPath/Bennu

# Track the publishment 
echo "$randKey	$whoami	$date	$dir $ans $newDir" >> publishLog.txt
mail -s "Published DTM $whoami $randKey $name" epalmer@psi.edu< cert.txt
mail -s "Published DTM $whoami $randKey $name" jweirich@psi.edu< cert.txt

# Clean up
rm publishedDate.txt 
#rm publishedDate.txt cert.txt



