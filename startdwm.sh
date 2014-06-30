#!/bin/sh

dwmstatus &

while true; do
	dwm 2> ~/.logs/dwm || exit
done
