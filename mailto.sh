#!/bin/sh

exec urxvt -name MAIL -e mutt -F ~/Dropbox/mutt/iandbrunton/muttrc $@
