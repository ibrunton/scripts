#!/bin/sh

emacsclient -n -e "(kill-buffer \"todo.org\")"
sudo /usr/sbin/pm-suspend
