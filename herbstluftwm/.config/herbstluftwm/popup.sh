#!/bin/bash

help () {
    echo -e "Usage: popup.sh [OPTIONS]"
    echo -e "Spawns a popup for a certain amount of time"
    echo -e ""
    echo -e "Options:"
    echo -e "  -m MESSAGE\t\tSpecifies message to be displayed"
    echo -e "  -t TIMEOUT\t\tAmount of time in seconds the popup is displayed"
    echo -e "  -u LEVEL\t\tUrgency level (info or high)"
}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$dir/theme.sh"

timeout=10
message=""
urgency="info"

while getopts ":m:t:x:y:w:h:u:" opt; do
    case $opt in
        m) message=$OPTARG ;;
        t) timeout=$OPTARG ;;
        u) urgency=$OPTARG ;;
    esac
done

if test ! $message; then
    help
else

    bar_opts="-f $font,$font_sec -B $acolor_bg -F $acolor_fg -g ${popup_width}x${height}+${popup_x}+${popup_y} -u 2"

    t=$(date +%T)

    if [ $urgency == "info" ]; then
        prefix="Info:"
    elif [ $urgency == "high" ]; then
        prefix="!!WARNING:"
    fi

    {
        echo "%{F$acolor_accent} $prefix %{F$acolor_fg}$message %{F$acolor_fg}($t)%{F-}"
        sleep $timeout
    } | bar $bar_opts
fi
