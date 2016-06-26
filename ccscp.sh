#!/bin/sh

for f in $@;
do
	scp $f debian@206.167.181.229:$f
done
