#!/bin/sh

if [ -z $1 ] ; then
	echo "usage: $0 ARCHIVE_NAME FILE [FILES]"
	exit 1
fi

ARCHIVE_NAME=$1
shift
DATE=`date "+%Y-%m-%d"`

sudo tarsnap cf $ARCHIVE_NAME-$DATE $@
