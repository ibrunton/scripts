#!/bin/sh

zmanim_url="http://www.chabad.org/tools/rss/zmanim.xml?c=206"
zmanim_file=$HOME/.local/share/zmanim
curl $zmanim_url -o $zmanim_file
