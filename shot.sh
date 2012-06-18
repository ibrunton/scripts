#!/bin/sh

# screenshot script by Ian Brunton <iandbrunton at gmail dot com>
# 2011-05-20
# takes a screenshot afte a delay, writes the image file in the
# Dropbox public folder, and creates a thumbnail that can be
# posted directly to boards without taking up too much space/bandwidth

basefilename=$HOME/Dropbox/Public/shots/`date +"%Y%m%d%H%M"`

screenshot=$basefilename.png
thumbnail=$basefilename-thumb.png

# take full-sized screen shot:
scrot -c -d 5 -q 100 $screenshot

# create thumbnail:
cp $screenshot $thumbnail
mogrify -resize 200x200 $thumbnail
