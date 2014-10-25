#!/bin/bash

help () {
    echo -e "Usage: popup.sh [OPTIONS]"
    echo -e "Spawns a popup for a certain amount of time"
    echo -e ""
    echo -e "Options:"
    echo -e "  -m MESSAGE\t\tSpecifies message to be displayed"
    echo -e "  -t TIMEOUT\t\tAmount of time in seconds the popup is displayed"
}

add_alpha_channel(){
    echo "$1" | \
    sed "s/.*#\([0-9a-fA-F]*\).*/#ff\1/"
}

timeout=10
message=""
x=0
y=0
width=120
height=90
urgency="info"

while getopts ":m:t:x:y:w:h:u:" opt; do
    case $opt in
        m) message=$OPTARG ;;
        t) timeout=$OPTARG ;;
        x) x=$OPTARG ;;
        y) y=$OPTARG ;;
        w) width=$OPTARG ;;
        h) height=$OPTARG ;;
        u) urgency=$OPTARG ;;
    esac
done

if test ! $message; then
    help
else
    light=$(add_alpha_channel $WM_LIGHT)
    llight=$(add_alpha_channel $WM_LLIGHT)
    accent=$(add_alpha_channel $WM_ACCENT)
    ldark=$(add_alpha_channel $WM_LDARK)
    dark=$(add_alpha_channel $WM_DARK)
    font="-*-fixed-medium-*-*-*-$(echo "$height - 10" | bc)-*-*-*-*-*-*-*"
    bar_opts="-f ${font} -B $dark -F $light -g ${width}x${height}+${x}+${y} -u 2"

    t=$(date +%T)

    if [ $urgency == "info" ]; then
        prefix="Info:"
    elif [ $urgency == "high" ]; then
        prefix="!!WARNING:"
    fi

    {
        echo "%{F$accent} $prefix %{F$light}$message %{F$llight}($t)%{F-}"
        sleep $timeout
    } | bar $bar_opts
fi
