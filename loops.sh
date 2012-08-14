#!/bin/sh

XDG_DATA_HOME=${XDG_DATA_HOME:-/home/ian/.local/share}

PACMAN_FILE=$XDG_DATA_HOME/pacman_count
AUR_FILE=$XDG_DATA_HOME/aur_count
WOLFSHIFT_FILE=$XDG_DATA_HOME/mailcount_wolfshift
IANDBRUNTON_FILE=$XDG_DATA_HOME/mailcount_iandbrunton
WINDOW_FILE=$XDG_DATA_HOME/hcwin

PACMAN_INTERVAL=600
MAIL_INTERVAL=300

while true ; do
	pacman=$(pacman -Qu | wc -l)
	echo $pacman > $PACMAN_FILE
	echo $(( $(yaourt -Qua | wc -l) - $pacman)) > $AUR_FILE
	sleep $PACMAN_INTERVAL
done &

while true ; do
	python $HOME/bin/gmail.py wolfshift > $WOLFSHIFT_FILE
	python $HOME/bin/gmail.py iandbrunton > $IANDBRUNTON_FILE
	sleep $MAIL_INTERVAL
done &

herbstclient --idle | while true ; do
	read line ||  break
	cmd=( $line )
	case "${cmd[0]}" in
		focus_changed|window_title_changed)
			echo "${cmd[@]:2}" > $WINDOW_FILE
			;;
	esac
done &
