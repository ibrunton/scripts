#!/bin/sh

emacsclient -n -e "(kill-buffer \"todo.org\")"
if [ -x /usr/sbin/pm-suspend ]
then
	ponymix set-volume 20
	sudo /usr/sbin/pm-suspend
else
	sudo systemctl suspend
fi
