#!/bin/sh

# various services needed only for DWM

#twmnd &

eval `cat ~/.fehbg` &

$HOME/scripts/check_mail.sh &
$HOME/scripts/dwmstatus &

while true; do
	dwm || exit
done
