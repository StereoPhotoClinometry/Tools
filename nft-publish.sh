# Eric E. palmer - 20 June 2017
# This builds the final version of an NFT feature
# Input filename needs a set format
#		nft-<6charid>-<version>.in
# 	Version 1.0
# We are putting the .in files in the group-controlled support directory
#		The .in will be under configuration management
# Configuaration in your woring directory
#	ln -s /opt/local/spc/shape4/support4 support
# 1 Nov 2019 - Update to work for NFT Actual Features


# Configuration parameters
path='nftConfig'
bigmapPath='/opt/local/spc/alt/bigmapo'
bigmapPath='/usr/local/bin/bigmap'
bigMapRefPath='/opt/local/spc/bin/bigMapRef'

# Check initial conditions before running
inFile=$1
if [ "$inFile" == "" ]
then
	echo "Usage:  $0 <feature infile>"
	echo "	Filename format:  nft-<6charid>-<version>.in"
exit
fi

# Make sure we have a bigmap input file.  
#		Typically, we expect it to be in lsupport
if [ -e $path/$inFile ]
then
	echo "Found it"
else
	echo "Could not find $path/$inFile"
exit
fi

# Check to make sure we have nftFitsConf
if [ -e nftFitsConfig.ini ]
then
	cat nftFitsConfig.ini
else
	echo "nftFitsConfig.ini is missing"
	exit
fi

# Internal check of feature name vs. input file
len=`echo $inFile | wc -c`
tmpLen=`echo $len - 4 | bc`
feature=`echo $inFile | cut -c 11-15`
version=`echo $inFile | cut -c 17-$tmpLen`
dir="nft-${feature}-${version}"


checkName=`head -5 $path/$inFile | tail -1`


#if [ "$feature" == "$checkName" ]
#then
#	echo "match"
#else
#	echo "Name mismatch:  $feature doesn't match $checkName"
#	echo "Fix the input file name for the output name"
#	exit
#fi

if [ -e nft-$feature-$version ]
then
	echo "Output directory exists: $dir"
	echo "We will not overwrite it"
exit
fi

if [ ! -e BIGMAP.IN ]
then
	echo "BIGMAP.IN does not exist"
	exit
fi

mkdir $dir

# Log some of the data
log="$dir/log-$feature.txt"
echo "Feature: $feature" | tee -a $log
echo "Version: $version" | tee -a $log
echo "check Name: $checkName" | tee -a $log
echo "Output directory: $dir" | tee -a $log


echo "Enter supporting information"
read info

#########
# Begin processing



echo "Info:   $info" | tee -a $log
echo "NFT Feature Name $feature" | tee -a $log

# Build the data
pwd
echo $path/$inFile
$bigmapPath < $path/$inFile | tee -a $log
echo "$feature$version" > tmpRun
cat $path/$inFile >> tmpRun
$bigMapRefPath < tmpRun | tee -a $log
rm tmpRun


# Save the data
d=`date`
echo "NFT Feature $feature run on: $d" | tee -a $log

p=`pwd`
host=`hostname`
echo "Working directory: $p $host" | tee -a $log

who=`whoami`
echo "Run by $who" | tee -a $log | tee -a $log

logFile="NFT-logfile.txt"
echo "$feature	$who $p $host $d" >> $logFile

cp $path/$inFile $dir

mv SIGMAS.pgm $dir
mv MAPFILES/$feature$version.MAP $dir
mv USED_PICS.TXT $dir
#mv SIGMAS.fits $dir

line=`tail -2 SIGMAS.TXT | head -1`
echo $line > $dir/SIGMAS.TXT
echo $line | tee -a $log

/bin/cp -f nftFitsConfig.ini $dir

tar cvf $feature-$version.tar $dir

