# 26 Sept 2017 - Eric E. Palmer
# Tests to see if the requested link already exists, and if
#		it is a symbolic link, remove it.  Otherwise, fail.

ex=$1
new=$2

#echo "ex $ex"
#echo "new $new"

if [ ! -e $ex ]
then
	echo "#################################"
	echo "The source file does not exist"
	exit
fi

if [ -L $new ]
then
	echo "Symbolic link found, removed"
	rm $new
fi

if [ -f $new ]
then
	echo "#################################"
	echo "Real file found, $new"
	exit
fi

cmnd="ln -s $ex $new"
echo $cmnd
`$cmnd`

