#!/bin/bash

while true; do

	bat_lvl=$(cat /sys/class/power_supply/BAT1/capacity)
    bat_stat=$(cat /sys/class/power_supply/BAT1/status)

    if [[ $bat_lvl -le 5 && $bat_stat == "Discharging" ]]; then
        $1 -m "Battery level critical: $bat_lvl%%" -u "high"
    elif [[ $bat_lvl -eq 10 && $bat_stat == "Discharging" ]]; then
        $1 -m "Battery level low: $bat_lvl%%"
    elif [[ $bat_lvl -eq 50 && $bat_stat == "Discharging" ]]; then
        $1 -m "Battery level at $bat_lvl%%"
    elif [[ $bat_lvl -eq 100 && $bat_stat == "Charging" ]]; then
        $1 -m "Battery fully charged"
    fi

    sleep 60;
done
