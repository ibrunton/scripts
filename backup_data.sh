#!/bin/sh

target_dir=/run/media/ian/VERBATIM-HD/sync/data/

if [ ! -d $target_dir ]
then
	echo "Target dir $target_dir does not exist!"
	mkdir -p $target_dir
fi

if [ ! -w $target_dir ]
then
	echo "Target dir $target_dir is not writeable!"
	exit 1
fi

rsync -r --exclude=virtualbox /mnt/data $target_dir
