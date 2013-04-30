#!/bin/sh

# script to start stuff for herbstluftwm

twmnd &

nitrogen --restore &

conky &
conky -c ~/.config/conky/side &
exec herbstluftwm
