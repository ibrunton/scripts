#!/bin/sh

for f in $@;
do
	scp $f debian@206.167.180.138:$f
done
