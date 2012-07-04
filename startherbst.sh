#!/bin/sh

# script to start stuff for herbstluftwm

twmnd &

nitrogen --restore &

#conky -c $HOME/.config/conky_herbstluftwm &
#$HOME/.config/herbstluftwm/dzen2.sh &

exec herbstluftwm
