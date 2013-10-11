#!/bin/sh

exec urxvtc -name MAIL -e mutt -F ~/Dropbox/mutt/iandbrunton/muttrc $@
