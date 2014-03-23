#!/bin/sh

for f in $@;
do
	scp $f dev@inke.acadiau.ca:newradial-dev/$f
done
