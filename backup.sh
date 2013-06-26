#!/bin/bash

hostname=$(hostname)
logfile=$HOME/.logs/rsync/$(date +"%Y-%m-%d")

# backup configs
source_dir=$HOME
target_dir=/mnt/sd/sync/$HOSTNAME/

rsync -r --safe-links $source_dir $target_dir >> $logfile

# backup data
source_dir=/mnt/data/
target_dir=/mnt/sd/sync/data

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

rsync -r $source_dir $target_dir >> $logfile

mkdir -p $HOME/pics/xedrbh/xedrbh/x
mkdir -p $HOME/pics/pics/wp

exit 0
