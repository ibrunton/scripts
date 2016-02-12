#!/bin/bash

hostname=$(hostname)
mkdir -p $HOME/.logs/rsync
logfile=$HOME/.logs/rsync/$(date +"%Y-%m-%d")
TARGET_ROOT=/run/media/ian/VERBATIM-HD/sync
MOVE_PICS=${MOVE_PICS:-YES}

# backup configs
source_dir=$HOME
target_dir=$TARGET_ROOT/$hostname/

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

echo "Backing up home directory..."
rsync -q -r --safe-links --exclude=/build/kernel $source_dir $target_dir 2>> $logfile

# backup system-wide configs
source_dir=/etc
echo "Backing up /etc..."
rsync -q -r --safe-links $source_dir $target_dir 2>> $logfile

# backup data
source_dir=/mnt/data/
target_dir=$TARGET_ROOT/data

if [ "${MOVE_PICS}" == "YES" ]; then
	echo "Moving pics for backup..."
	y=$(date +"%Y")
	m=$(date +"%m")
	d=$(date +"%d")

	for f in $HOME/pics/xedrbh/xedrbh/* ;
	do
		newf1=$(echo "$f" | tr ' :' '_-' | tr A-Z a-z | sed 's/jpe$/jpg/')
		if [[ ! -e $newf1 ]]
		then
			mv "$f" $newf1
		fi
	done

	for f in $HOME/pics/xedrbh/xedrbh/x/* ;
	do
		newf1=$(echo "$f" | tr ' :' '_-' | tr A-Z a-z | sed 's/jpe$/jpg/')
		if [[ ! -e $newf1 ]]
		then
			mv "$f" $newf1
		fi
	done

	for f in $HOME/pics/pics/* ;
	do
		newf1=$(echo "$f" | tr ' :' '_-' | tr A-Z a-z | sed 's/jpe$/jpg/')
		if [[ ! -e $newf1 ]]
		then
			mv "$f" $newf1
		fi
	done

	if [ "$(ls -A $HOME/pics/pics/wp)" ] ; then
		mv $HOME/pics/pics/wp/* $HOME/pics/wp/
	fi

	rmdir $HOME/pics/pics/wp

	mkdir -p $HOME/pics/saved/$y/$m
	mv $HOME/pics/pics $HOME/pics/saved/$y/$m/$d

	mkdir -p $HOME/pics/xedrbh/saved/$y/$m
	mv $HOME/pics/xedrbh/xedrbh $HOME/pics/xedrbh/saved/$y/$m/$d
fi

echo "Backing up data..."
rsync -q -r --exclude=virtualbox $source_dir $target_dir 2>> $logfile

mkdir -p $HOME/pics/xedrbh/xedrbh/x
mkdir -p $HOME/pics/pics/wp

exit 0
