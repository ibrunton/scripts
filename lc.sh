#!/bin/bash

for f in *; do
	newf=$(echo "$f" | tr "A-Z " "a-z_")
	if [ ! -e $newf ]
	then
		mv "$f" $newf
	fi
done
