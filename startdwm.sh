#!/bin/sh

#xfce4-power-manager &

# various services needed only for DWM
twmnd &

nitrogen --restore &

#conky -c $HOME/.config/conky_dwm | while read -r; do xsetroot -name "$REPLY"; done &

#$HOME/bin/trayer.sh &
$HOME/bin/loops.sh &

while true; do
	dwm || exit
done
