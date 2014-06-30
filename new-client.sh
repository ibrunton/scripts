#!/bin/sh

if [ -z $1 ] ;
then
	echo "usage: $0 NAME"
	exit 1
fi

client_name=$1
client_dir=$HOME/Dropbox/docs/training/clients/$client_name

mkdir -p $client_dir

touch $client_dir/{contact,program.org,sessions}
