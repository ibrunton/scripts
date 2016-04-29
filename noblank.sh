#!/bin/sh

off() {
	echo "Turning screen-saving features off."

	xset s off
	xset s noblank
	xset -dpms

	$HOME/scripts/toggle.sh noblank
}

on() {
	echo "Turning screen-saving features on."

	xset s on
	xset s blank
	xset +dpms

	$HOME/scripts/toggle.sh noblank
}

"$1"
