#!/bin/bash

mostused="
chat ~/scripts/chat.sh
firefox
nitrogen
screenshot ~/scripts/shot.sh
writer lowriter"

result=$(echo "$mostused" | dmenu -fn "-misc-ohsnap-medium-r-normal--11-79-100-100-c-60-iso8859-1" -nb "#000000" -nf "#e0e0e0" -sb "#000000" -sf "#4abcd4")
cmd=$(echo "$result" | cut -d' ' -f2-)
[ -n "$cmd" ] && eval setsid setsid "$cmd"
