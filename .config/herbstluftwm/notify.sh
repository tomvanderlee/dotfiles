#!/bin/bash

monitor_w=$1
window_p=$2
panel_h=$3

popup_w=$(echo "$monitor_w - (2 * $window_p)" | bc)
popup_h=$panel_h
popup_x=$window_p
popup_y=$window_p

popup_opts="-w $popup_w -h $popup_h -x $popup_x -y $popup_y"

while true; do

	bat_lvl=$(cat /sys/class/power_supply/BAT1/capacity)
    bat_stat=$(cat /sys/class/power_supply/BAT1/status)
    
    if [[ $bat_lvl -le 5 && $bat_stat == "Discharging" ]]; then
        $4 -m "Battery level critical: $bat_lvl%%" -u "high" $popup_opts
    elif [[ $bat_lvl -eq 10 && $bat_stat == "Discharging" ]]; then
        $4 -m "Battery level low: $bat_lvl%%" $popup_opts
    elif [[ $bat_lvl -eq 50 && $bat_stat == "Discharging" ]]; then
        $4 -m "Battery level at $bat_lvl%%" $popup_opts
    elif [[ $bat_lvl -eq 100 && $bat_stat == "Charging" ]]; then
        $4 -m "Battery fully charged"
    fi

    sleep 60;
done
