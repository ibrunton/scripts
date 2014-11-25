#!/bin/sh

off() {
	echo "Turning screen-saving features off."

	xset s off
	xset s noblank
	xset -dpms
}

on() {
	echo "Turning screen-saving features on."

	xset s on
	xset s blank
	xset +dpms
}

"$1"
