#!/bin/sh

XDG_DATA_HOME=${XDG_DATA_HOME:-/home/ian/.local/share}

PACMAN_FILE=$XDG_DATA_HOME/pacman_count
AUR_FILE=$XDG_DATA_HOME/aur_count
WOLFSHIFT_FILE=$XDG_DATA_HOME/mailcount_wolfshift
IANDBRUNTON_FILE=$XDG_DATA_HOME/mailcount_iandbrunton

PACMAN_INTERVAL=600
MAIL_INTERVAL=300

while true ; do
	pacman -Qu | wc -l > $PACMAN_FILE
	yaourt -Qu | wc -l > $AUR_FILE
	sleep $PACMAN_INTERVAL
done &

while true ; do
	python $HOME/bin/gmail.py wolfshift > $WOLFSHIFT_FILE
	python $HOME/bin/gmail.py iandbrunton > $IANDBRUNTON_FILE
	sleep $MAIL_INTERVAL
done &
