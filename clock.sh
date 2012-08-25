#!/bin/sh

while true ; do
	newtime=$(date +"%H:%M:%S")
	echo -en "\r$newtime  \b\b"
	sleep 1
done
