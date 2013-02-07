#!/bin/sh

# toggles window title

FILENAME=$1
LONGNAME=$HOME/.local/share/${FILENAME}-
if [ -e $LONGNAME"on" ]; then
	mv $LONGNAME"on" $LONGNAME"off"
else
	mv $LONGNAME"off" $LONGNAME"on"
fi

exit
