#!/bin/sh

exec urxvt -name MAILTO -e mutt -F ~/Dropbox/mutt/iandbrunton/muttrc $@
