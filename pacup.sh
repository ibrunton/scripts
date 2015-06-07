#!/bin/sh

pacman -Qu > $HOME/.logs/pacman/`date "+%Y-%m-%d_%H%M"`
#yaourt -Su --ignore firefox
sudo pacman -Su
