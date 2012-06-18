#!/bin/sh

conky -c ~/.config/conky_awesome | while read -r; do echo "conky.text = \"$REPLY\"" | awesome-client; done
