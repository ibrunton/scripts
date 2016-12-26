#!/bin/sh

FILE=$HOME/.local/share/volume

case "$1" in
	up)
		ponymix increase 1 > $FILE
		;;
	down)
		ponymix decrease 1 > $FILE
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
