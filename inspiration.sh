#!/bin/bash

# 2013-07-07 Sun by Ian D. Brunton <iandbrunton at gmail dot com>
#
# usage: inspiration backup
# 		creates a file listing link names and their targets
# usage: inspiration restore [filename]
#		restores links from file.  If filename is not supplied,
#		uses most recent available.

inspiration_dir=$HOME/pics/xedrbh/inspiration
file=$HOME/pics/xedrbh/inspiration/.lists

case "$1" in
	backup)
		if [ ! -d $file ] ; then
			mkdir -p $file
		fi

		file=$file/$(date +"%y-%m-%d")
		if [ -e $file ] ; then
			echo -n "File $file already exists.  Overwrite? (y/n)"
			read answer
			if [ $answer = "n" ] ; then
				exit 0
			fi
		fi

		for f in $inspiration_dir/*.*; do
			if [ -L $f ] ; then
				echo -n $f >> $file
				echo -en "\t" >> $file
				readlink $f >> $file
			else
				echo "Skipping regular file $f."
			fi
		done
		;;

	restore)
		if [ -z "$2" ] ; then
			this=$(ls -t $file | head -n 1)
		else
			this="$2"
		fi

		if [ -z "$this" ] ; then
			echo "No file available."
			exit 1
		fi

		file=$file/$this
		if [ ! -e $file ] ; then
			echo "File $file does not exist!"
			exit 1
		fi

		while read line
		do
			target=$(echo $line | awk '{print $2}')
			name=$(echo $line | awk '{print $1}')
			echo -n "Linking $name to $target..."
			if [ -e $name ] ; then
				if [ $(readlink $name) != $target ] ; then
					echo -n "$name already linked to another file.  Overwrite? (y/n)"
					read answer
					if [ $answer = "y" ] ; then
						ln -fs $target $inspiration_dir/$name
					fi
				fi
			else
				if [ ! -e $target ] ; then
					echo "$target does not exist."
				else
					ln -s $target $inspiration_dir/$name
					echo "done."
				fi
			fi
		done < "$file"
		;;

	*)
		echo "usage: inspiration [backup|restore [file]]"
		;;
esac