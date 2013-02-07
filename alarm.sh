#!/bin/bash

# 2012-11-05 by Ian D Brunton < iandbrunton at gmail dot dom >
# Sets volume (both amixer and mpd), loads a playlist,
# and plays a random track.
# Designed to be run by cron as an alarm clock.

VOLUME_FILE=$HOME/.local/share/volume
display_volume=$(amixer set Master 85% unmute | grep -m 1 "%]" | cut -d "[" -f 2 | cut -d "%" -f 1)
echo $display_volume > $VOLUME_FILE
mpc volume 55
mpc clear
mpc load wakeup
mpc shuffle
mpc play
notify-send "good morning"
