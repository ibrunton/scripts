#!/bin/sh

XDG_DATA_HOME=${XDG_DATA_HOME:-/home/ian/.local/share}
WOLFSHIFT_FILE=$XDG_DATA_HOME/mailcount_wolfshift
IANDBRUNTON_FILE=$XDG_DATA_HOME/mailcount_iandbrunton
MAIL_INTERVAL=300

while true ; do
	python2 $HOME/scripts/gmail.py wolfshift > $WOLFSHIFT_FILE
	python2 $HOME/scripts/gmail.py iandbrunton > $IANDBRUNTON_FILE
	sleep $MAIL_INTERVAL
done &
