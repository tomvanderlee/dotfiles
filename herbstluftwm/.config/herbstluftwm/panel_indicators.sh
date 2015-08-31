#!/usr/bin/env bash

icon_font="FontAwesome-10"

battery_icon=("\uf244" "\uf243" "\uf242" "\uf241" "\uf240" "\uf1e6")
network_icon=("\uf1eb" "\uf109")
music_icon="\uf001"
volume_icon=("\uf026" "\uf027" "\uf028")

music()
{
    # Music
    player_status=$(playerctl status)
    if [ $player_status = "Playing" ]; then
        player_artist=$(playerctl metadata artist)
        player_title=$(playerctl metadata title)
        playing="$player_title - $player_artist"

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

volume()
{
    # Volume
    if pgrep pulseaudio >> /dev/null ; then
        volumes=$(\
            amixer get Master | \
            grep "Front Right: Playback"\
            )
        vol=$(\
            echo $volumes | \
            sed "s/.*\[\([0-9]*\)%\].*/\1/"\
            )
        if [ -z $vol ] ; then
            vol_status="off"
        elif [ $vol -eq 0 ]; then
            vol_status="%{F$acolor_fg}${volume_icon[0]} $vol%%{F-}"
        elif [ $vol -lt 33 ]; then
            vol_status="%{F$acolor_fg}${volume_icon[1]} $vol%%{F-}"
        else
            vol_status="%{F$acolor_fg}${volume_icon[2]} $vol%%{F-}"
        fi
        echo -e "volume\t$vol_status"
    else
        echo -e "volume\toff"
    fi
}

network()
{
    # Network
    read lo int1 int2 <<< `ip link | sed -n 's/^[0-9]: \(.*\):.*$/\1/p'`
    if iwconfig $int1 >/dev/null 2>&1; then
        wifi=$int1
        eth=$int2
    else
        wifi=$int2
        eth=$int1
    fi

    ip link show $eth | grep 'state UP' >/dev/null && int=$eth || int=$wifi

    if [ $int == $wifi ] ; then
        iwconfig=$(iwconfig $int)
        ssid=$(
        echo $iwconfig | \
            sed "s/.*ESSID:\(\".*\"\).*/\1/" | \
            sed "s/.*\(off\/any\).*/\"\1\"/" | \
            sed "s/.*\"\(.*\)\".*/\1/"
        )

        quality=$( \
            echo $iwconfig | \
            sed "s/^.*Link Quality=\([0-9]*\)\/\([0-9]*\) .*$/(\1*100)\/\2/" | \
            bc
        )

        if [ $ssid == "off/any" ] ; then
            net_status="off"
        else
            net_status="${network_icon[0]} $ssid $quality%"
        fi

    elif [ $int == $eth ] ; then
        net_status="${network_icon[1]} Ethernet"
    else
        net_status="off"
    fi

    echo -e "net\t$net_status"
}

battery()
{
    # Batteries
    bat_info="off"
    for bat in $(find /sys/class/power_supply | grep BAT); do
        nr="${bat: -1}"
        bat_info=""

        bat_lvl=$(cat /sys/class/power_supply/BAT0/capacity)
        bat_state=$(cat /sys/class/power_supply/BAT0/status)

        if [ $bat_state == "Charging" ] ; then
            bat_status="${battery_icon[5]}"
        elif [ $bat_lvl -lt 10 ] ; then
            bat_status="${F$acolor_accent}${battery_icon[0]}${F-}"
        elif [ $bat_ -lt 25 ] ; then
            bat_status="${battery_icon[1]}"
        elif [ $bat_ -lt 50 ] ; then
            bat_status="${battery_icon[2]}"
        elif [ $bat_lvl -lt 75 ] ; then
            bat_status="${battery_icon[3]}"
        else
            bat_status="${battery_icon[4]}"
        fi

        bat_info+="$nr: $bat_status $bat_lvl%%{F-}"
    done
    echo -e "battery\t$bat_info"
}

clock()
{
    echo -e $(date +$"date\t%{F$acolor_fg}%H:%M:%S %{F$acolor_fg}(%d-%m-%Y)%{F-}")
}

# vim: set ts=4 sw=4 tw=0 et :
