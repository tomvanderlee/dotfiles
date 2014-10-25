#!/bin/bash

SCREENCAP="/tmp/lock.png"
scrot $SCREENCAP
convert -gaussian-blur "12x3" $SCREENCAP $SCREENCAP
i3lock -i $SCREENCAP
rm $SCREENCAP 
