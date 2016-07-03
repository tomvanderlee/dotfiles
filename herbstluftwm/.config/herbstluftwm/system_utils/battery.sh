#!/usr/bin/env bash

hlwm_utils_battery() {
    for bat in $(find /sys/class/power_supply | grep BAT); do
        bat_nr="${bat: -1}"
        bat_lvl=$(cat "/sys/class/power_supply/BAT$bat_nr/capacity")
        bat_state=$(cat "/sys/class/power_supply/BAT$bat_nr/status")

        echo "$bat_nr $bat_state $bat_lvl"
    done
}
# vim: set ts=8 sw=4 tw=0 et :
