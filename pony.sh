#!/bin/sh

FILE=$HOME/.local/share/volume
INC=1

if [ ! -z "$2" ]
then
	INC="$2"
fi

case "$1" in
	up)
		ponymix increase $INC > $FILE
		;;
	down)
		ponymix decrease $INC > $FILE
		;;
	mute|unmute|toggle)
		ponymix toggle > $FILE
		ponymix is-muted && echo "0" > $FILE
		;;
	reset)
		ponymix set-volume 20 > $FILE
		;;
	*)
		ponymix set-volume "$1" > $FILE
		;;
esac
