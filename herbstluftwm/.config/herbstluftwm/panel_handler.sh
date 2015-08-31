#!/usr/bin/env bash

#Handle clickable areas
while read line; do
    IFS=',' read -a c <<< $(echo $line)
    case "${c[0]}" in
        tag)
            herbstclient use "${c[1]}"
            echo "herbstclient use \"${c[1]}\""
            ;;
        *)
            echo "${c[0]}: not valid command"
            ;;
    esac
done

# vim: set ts=4 sw=4 tw=0 et :
