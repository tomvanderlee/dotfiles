#!/bin/sh

SCREENCAP="/tmp/lock.png"
scrot $SCREENCAP
convert -scale 10% -scale 1000% $SCREENCAP $SCREENCAP
i3lock -i $SCREENCAP
rm $SCREENCAP 
