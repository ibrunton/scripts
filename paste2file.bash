#!/bin/bash
# clippaste - Paste contents of clipboard to file in terminal.

# Program name from it's filename
prog=${0##*/}

# Text color variables
bldblu='\e[1;34m'         # blue
bldred='\e[1;31m'         # red
bldwht='\e[1;37m'         # white
txtbld=$(tput bold)       # bold
txtund=$(tput sgr 0 1)    # underline
txtrst='\e[0m'            # text reset
info=${bldwht}*${txtrst}
pass=${bldblu}*${txtrst}
warn=${bldred}!${txtrst}

filename=$@
pasteinfo="clipboard contents"

# usage if argument isn't given
if [[ -z $filename ]]; then
  echo "clippaste <filename> - paste contents of context-menu clipboard to file"
  exit
fi

# check if file exists, prompt to append or override, else create new
if [[ -f $filename ]]; then
  echo -en "$warn File ${txtund}$filename${txtrst} already exists - (${txtbld}e${txtrst})xit, (${txtbld}a${txtrst})ppend, (${txtbld}o${txtrst})verwrite: "
  read edit
  case "$edit" in
    [aA] )  xclip -out -selection clipboard >> $filename
            echo -e "$pass File ${txtund}$filename${txtrst} appended with clipboard contents"
            ;;
    [oO] )  xclip -out -selection clipboard > $filename
            echo -e "$pass File ${txtund}$filename${txtrst} overwrote with clipboard contents"
            ;;
    * )     exit
    esac; else
    xclip -out -selection clipboard >> $filename
    echo -e "$pass File ${txtund}"$filename"${txtrst} created with clipboard contents"
fi