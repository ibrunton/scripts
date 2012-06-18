#!/bin/sh

# Commands to execute when exiting window manager/X.
# Call this script from the window manager's auto-stop function,
# if it has one.

emacsclient -e "(recentf-save-list)"
