#!/bin/sh

# toggles window title

LONGNAME=$HOME/.local/share/hcwin-
if [ -e $LONGNAME"on" ]; then
	mv $LONGNAME"on" $LONGNAME"off"
else
	mv $LONGNAME"off" $LONGNAME"on"
fi

exit
