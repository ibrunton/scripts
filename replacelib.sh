#!/bin/sh

# This script is for copying updated modules to the appropriate directory
# without having to track the directory down every time.
# 2011-12-31

if [ -z $1 ]
then
	echo "Please specify which library you wish to copy"
	exit
fi

lib=$1
sudo cp $1 /usr/lib/perl5/vendor_perl/
