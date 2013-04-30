#!/bin/sh

# screenshot script by Ian Brunton <iandbrunton at gmail dot com>
# 2011-05-20, 2012-06-23
#
# 1. Takes a screenshot after $DELAY
# 2. Saves screenshot in Dropbox public folder
# 3. Creates a thumbnail suitable for forum posting
# 4. Begins a forum post with Dropbox public URLs inserted
# 5. Opens the draft post in $EDITOR
#
# Draft post template:
# [url=#SCREENSHOT#][img]#THUMBNAIL#[/img][/url]

basefilename=$HOME/Dropbox/Public/shots/`date +"%Y%m%d%H%M"`
screenshot=$basefilename.png
thumbnail=$basefilename-thumb.png
DELAY=5 # seconds

# take full-sized screen shot:
scrot -c -d $DELAY -q 100 $screenshot

# create thumbnail:
convert -resize 200x200 $screenshot $thumbnail

ss_url=`dropbox puburl $screenshot`
th_url=`dropbox puburl $thumbnail`
forum_post=$HOME/docs/drafts/arch_screenshot_`date +'%Y-%m-%d'`

sed "s,#SCREENSHOT#,$ss_url,g
     s,#THUMBNAIL#,$th_url,g" <$HOME/Dropbox/templates/forum_screenshot >>$forum_post

$EDITOR $forum_post
