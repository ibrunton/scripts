#!/bin/sh

# toggles conky and herbstluftwm padding

LONGNAME=$HOME/.local/share/conky-
if [ -e $LONGNAME"on" ]; then
	mv $LONGNAME"on" $LONGNAME"off"
	herbstclient pad 0 0 0 0
else
	mv $LONGNAME"off" $LONGNAME"on"
	herbstclient pad 0 16 0 0
fi

exit
