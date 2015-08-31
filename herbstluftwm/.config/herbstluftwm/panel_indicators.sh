#!/usr/bin/env bash
icon_font="FontAwesome-10"
battery_icon=("\ue113" "\ue114" "\ue115" "\ue116" "\ue042")
network_icon=("\ue0f1" "\ue0f2" "\ue0f3" "\ue0af")
music_icon="\ue05c"

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
            echo -e "volume\toff"
        else
            echo -e "volume\t%{F$acolor_fg}\ue05d $vol%%{F-}"
        fi
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
            echo -e "net\toff"
        elif [ $quality -lt 33 ] ; then
            echo -e "net\t${network_icon[0]} $ssid"
        elif [ $quality -lt 66 ] ; then
            echo -e "net\t${network_icon[1]} $ssid"
        else
            echo -e "net\t${network_icon[2]} $ssid"
        fi

    elif [ $int == $eth ] ; then
        echo -e "net\t${network_icon[3]} ethernet"
    else
        echo -e "net\toff"
    fi
}

battery()
{
    # Battery
    if $(test -e /sys/class/power_supply/BAT1) ; then

        bat_lvl=$(cat /sys/class/power_supply/BAT1/capacity)
        bat_state=$(cat /sys/class/power_supply/BAT1/status)

        if [ $bat_state == "Charging" ] ; then
            bat_status="${battery_icon[4]}"
        elif [ $bat_lvl -lt 10 ] ; then
            bat_status="${F$acolor_accent}${battery_icon[0]}${F-}"
        elif [ $bat_ -lt 33 ] ; then
            bat_status="${battery_icon[1]}"
        elif [ $bat_lvl -lt 66 ] ; then
            bat_status="${battery_icon[2]}"
        else
            bat_status="${battery_icon[3]}"
        fi

        echo -e "battery\t$bat_status $bat_lvl%%%{F-}"
    else
        echo -e "battery\toff"
    fi
}

clock()
{
    echo -e $(date +$"date\t%{F$acolor_fg}%H:%M:%S %{F$acolor_fg}(%d-%m-%Y)%{F-}")
}
