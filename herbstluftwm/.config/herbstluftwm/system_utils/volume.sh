#!/usr/bin/env bash

hlwm_utils_volume() {
    local status=($(amixer get Master | sed -rn 's/\s*Front Right.*\[([0-9]+)%\]\s+\[(on|off)\]/\1 \2/p'))
    if [ "${status[1]}" == "off" ]; then
        echo "mute"
    else
        echo "${status[0]}"
    fi
}
# vim: set ts=8 sw=4 tw=0 et :
