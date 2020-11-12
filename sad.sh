#!/bin/sh

DATE=`date +"%Y-%m-%d"`
DIR=$HOME/.logs/apt-mx
FILE="${DIR}/${DATE}"

apt list --upgradable > $FILE
sudo apt dist-upgrade
