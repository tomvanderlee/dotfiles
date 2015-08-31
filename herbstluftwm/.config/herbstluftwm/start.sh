#!/usr/bin/env bash

opts=($@)

program=$(echo ${opts[0]} | sed 's/^.*\/\(.*\)/\1/')

if pgrep $program >> /dev/null
then
    killall $program
    ${opts[@]} &
else
    ${opts[@]} &
fi
