#!/usr/bin/env bash

source "$HLWM_CONF_DIR/system_utils/all.sh"

export icon_font="FontAwesome-10"

battery_icon=("\uf244" "\uf243" "\uf242" "\uf241" "\uf240" "\uf1e6")
network_icon=("\uf1eb" "\uf109")
music_icon="\uf001"
volume_icon=("\uf026" "\uf027" "\uf028")
backlight_icon="\uf185"

hlwm_indicator_music()
{
    playing=$(hlwm_utils_music_playing)

    if [ -n "$playing" ]; then
        if [ "$current" != "$playing" ] ; then
            current=$playing
            scrolling=$current
        elif [ ${#scrolling} -gt "24" ] ; then
            scrolling=${scrolling:1}
        else
            scrolling=$current
        fi

        echo -e "music\t$music_icon ${scrolling:0:24}"
    else
        echo -e "music\toff"
    fi
}

hlwm_indicator_volume()
{
    # Volume
    if pgrep pulseaudio >> /dev/null ; then
        volume=$(hlwm_utils_volume)
        if [ -z "$volume" ]; then
            volume_status="off"
        elif [ "$volume" == "mute" ]; then
            volume_status="%{F$HLWM_FG_ACOLOR}${volume_icon[0]} Mute%{F-}"
        elif [ "$volume" -eq 0 ]; then
            volume_status="%{F$HLWM_FG_ACOLOR}${volume_icon[0]} $volume%%{F-}"
        elif [ "$volume" -lt 33 ]; then
            volume_status="%{F$HLWM_FG_ACOLOR}${volume_icon[1]} $volume%%{F-}"
        else
            volume_status="%{F$HLWM_FG_ACOLOR}${volume_icon[2]} $volume%%{F-}"
        fi
        echo -e "volume\t$volume_status"
    else
        echo -e "volume\toff"
    fi
}

hlwm_indicator_network()
{
    # Network
    conn=$(hlwm_utils_active_network)
    conn_type=$(echo "$conn" | cut -d: -f1)

    if [ "$conn_type" = "wifi" ] ; then
        ssid=$(echo "$conn" | cut -d: -f2)
        quality=$(echo "$conn" | cut -d: -f3)
        net_status="${network_icon[0]} $ssid $quality%"
    elif [ "$conn_type" = "eth" ] ; then
        name=$(echo "$conn" | cut -d: -f2)
        net_status="${network_icon[1]} $name"
    else
        net_status="off"
    fi

    echo -e "net\t$net_status"
}

hlwm_indicator_battery()
{
    # Batteries
    battery_info=""
    while read -r battery; do

        battery=($battery)
        battery_nr=${battery[0]}
        battery_status=${battery[1]}
        battery_level=${battery[2]}

        if [ "$battery_status" = "Charging" ] ; then
            battery_status="${battery_icon[5]}"
        elif [ "$battery_level" -lt 5 ]; then
            systemctl suspend;
        elif [ "$battery_level" -lt 10 ] ; then
            battery_status="%{F$HLWM_ACCENT_ACOLOR}${battery_icon[0]}%{F-}"
        elif [ "$battery_level" -lt 25 ] ; then
            battery_status="${battery_icon[1]}"
        elif [ "$battery_level" -lt 50 ] ; then
            battery_status="${battery_icon[2]}"
        elif [ "$battery_level" -lt 75 ] ; then
            battery_status="${battery_icon[3]}"
        else
            battery_status="${battery_icon[4]}"
        fi

        battery_info+="$battery_nr: $battery_status $battery_level%%{F-}"
    done < <(hlwm_utils_battery)

    if [ -z "$battery_info" ] ; then
        echo -e "battery\toff"
    else
        echo -e "battery\t$battery_info"
    fi
}

hlwm_indicator_clock()
{
    datetime=$(hlwm_utils_datetime)
    datetime=($datetime)

    date=${datetime[0]}
    time=${datetime[1]}

    echo -e "date\t%{F$HLWM_FG_ACOLOR}$time %{F$HLWM_FG_ACOLOR}($date)%{F-}"
}

hlwm_indicator_backlight() {
    local level=$(hlwm_utils_backlight)

    if [ -z "$level" ]; then
        echo -e "backlight\toff"
    else
        echo -e "backlight\t$backlight_icon $level%"
    fi
}

# vim: set ts=4 sw=4 tw=0 et :
