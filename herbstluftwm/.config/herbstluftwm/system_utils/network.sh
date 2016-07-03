#!/usr/bin/env bash

hlwm_utils_active_network() {
    network=""

    wifi=""
    eth=""

    devices="$(nmcli -t -f type,state,device d)"
    for device in $devices; do
        type=$(echo "$device" | cut -d: -f1)
        state=$(echo "$device" | cut -d: -f2)
        hwdevice=$(echo "$device" | cut -d: -f3)

        if [ "$state" != "connected" ]; then
            continue
        elif [ "$type" = "wifi" ]; then
            wifi="$hwdevice"
        elif [ "$type" = "ethernet" ]; then
            eth="$hwdevice"
        fi
    done

    if [ -n "$wifi" ]; then
        wifi_list=$(nmcli -t -f in-use,ssid,signal d wifi list ifname "$wifi")
        network="wifi:$(echo "$wifi_list" | sed -n 's/^\*:\(.*\)$/\1/p')"
    elif [ -n "$eth" ]; then
        network_info=$(nmcli -t d show "$eth")
        network="eth:$(echo "$network_info" | sed -n 's/^GENERAL.CONNECTION:\(.*\)$/\1/p')"
    fi

    echo "$network"
}
# vim: set ts=8 sw=4 tw=0 et :
