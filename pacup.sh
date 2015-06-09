#!/bin/sh

pacman -Qu > $HOME/.logs/pacman/`date "+%Y-%m-%d_%H%M"`

sudo pacman -Su
