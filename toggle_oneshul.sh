#!/bin/sh

# toggles herbstluftwm layout for tag 2 to optimise for OneShul.org services

LONGNAME=$HOME/.local/share/oneshul-
if [ -e $LONGNAME"on" ]; then
	mv $LONGNAME"on" $LONGNAME"off"
	herbstclient load 2 "(split horizontal:0.750000:0 (clients horizontal:0) (clients horizontal:1))"
else
	mv $LONGNAME"off" $LONGNAME"on"
	herbstclient load 2 "(split vertical:0.500000:0 (clients horizontal:0) (clients horizontal:0))"
fi

exit
