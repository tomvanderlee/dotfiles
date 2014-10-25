#!/bin/bash

hc() {
	"${herbstclient_command[@]:-herbstclient}" "$@" ;
}

add_alpha_channel(){
	echo "$1" | \
	sed "s/.*#\([0-9a-fA-F]*\).*/#ff\1/"
}

monitor=${1:-0}
panel_height=$2
padding=$3

light=$(add_alpha_channel $WM_LIGHT)
llight=$(add_alpha_channel $WM_LLIGHT)
accent=$(add_alpha_channel $WM_ACCENT)
ldark=$(add_alpha_channel $WM_LDARK)
dark=$(add_alpha_channel $WM_DARK)

font="-*-fixed-medium-*-*-*-14-*-*-*-*-*-*-*"
#font=""
selected_bg=$accent
normal_bg=$dark
selected_txt=$dark
normal_txt=$light
inactive_txt=$llight

geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=$(echo "${geometry[0]} + $padding" | bc)
y=$(echo "${geometry[1]} + $padding" | bc)
panel_width=$(echo "${geometry[2]} - (2 * $padding)" | bc)
bar_opts="-g ${panel_width}x${panel_height}+${x}+${y} -f ${font} -u 2 -B ${normal_bg} -F ${normal_txt}"

hc pad $monitor $(echo "$panel_height + $padding" | bc)

if awk -Wv 2>/dev/null | head -1 | grep -q '^mawk'; then
    # mawk needs "-W interactive" to line-buffer stdout correctly
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=593504
    uniq_linebuffered() {
      awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
else
    # other awk versions (e.g. gawk) issue a warning with "-W interactive", so
    # we don't want to use it there.
    uniq_linebuffered() {
      awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
fi

{
    ### Event generator ###
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29

    while true ; do
		# Volume
		if pgrep pulseaudio > /dev/null ; then
			volumes=$(\
				amixer get Master | \
				grep "Mono: Playback"\
			)
			vol=$(\
				echo $volumes | \
				sed "s/.*\[\([0-9]*\)%\].*/\1/"\
			)
			if [ -z $vol ] ; then
				echo -e "volume\toff"
			elif [ $vol -le 0 ] ; then
				echo -e "volume\t%{F$normal_txt}Volume muted"
			else
				echo -e "volume\t%{F$normal_txt}Volume: $vol%%%{F-}"
			fi
		else
			echo -e "volume\toff"
		fi

		# Network
		iwconfig=$(iwconfig wlp3s0)
		if [ -z $iwconfig ] ; then
			echo -e "net\toff"
		else
			ssid=$(\
				echo $iwconfig | \
				sed "s/.*ESSID:\(\".*\"\).*/\1/" | \
				sed "s/.*\(off\/any\).*/\"\1\"/" | \
				sed "s/.*\"\(.*\)\".*/\1/"\
			)
			if [ $ssid = "off/any" ] ; then
				ifconf=$
				echo -e "net\t%{F$normal_txt}Net: No connection%{F-}"
			else
				echo -e "net\t%{F$normal_txt}Net: $ssid%{F-}"
			fi
		fi

		# Battery
		if $(test -e /sys/class/power_supply/BAT1) ; then
			bat_lvl=$(cat /sys/class/power_supply/BAT1/capacity)
			if [ $bat_lvl -lt 15 ] ;	then
				bat_color=$accent
			else
				bat_color=$normal_txt
			fi
			state=$(cat /sys/class/power_supply/BAT1/status)
			echo -e "battery\t%{F$normal_txt}$state: %{F$bat_color}$bat_lvl%{F$normal_txt}%%%{F-}"
		else
			echo -e "battery\toff"
		fi

		# Time
        echo -e $(date +$"date\t%{F$normal_txt}%H:%M:%S %{F$inactive_txt}(%d-%m-%Y)%{F-}")
        sleep 1 || break
    done > >(uniq_linebuffered) &
    childpid=$!
    hc --idle
    kill $childpid
} 2> /dev/null | {

    IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
    visible=true
    date=""
	volume=""
	battery=""
	net=""
    windowtitle=""
    while true ; do
        separator="%{F$accent}|%{F-}"
        # draw tags
        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "%{U$accent+u}%{B-}%{F$normal_txt}"
                    ;;
                '+')
                    echo -n "%{B$accent}%{F$normal_bg}"
                    ;;
                ':')
                    echo -n "%{B-}%{F$normal_txt}"
                    ;;
                '!')
                    echo -n "%{B$normal_txt}%{F$normal_bg}"
                    ;;
                *)
                    echo -n "%{B-}%{F$inactive_txt}"
                    ;;
            esac
            echo -n "%{A:tag,${i:1}:} ${i:1} %{A}%{F-}%{B-}%{U-u}"
        done
        echo -n "$separator"
        echo -n "%{B-}%{F-} ${windowtitle//^/^^}"

		#Right part of panel
        right="$volume$net$battery$date "
        echo -n "%{r}$right"
        echo

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
			volume)
				volume="${cmd[@]:1}"
				if [ $volume == "off" ] ; then
					volume=""
				else
					volume="$volume $separator%{B-} "
				fi
				;;
			net)
				net="${cmd[@]:1}"
				if [ $net = "off" ] ; then
					net=""
				else
					net="$net $separator%{B-} "
				fi
				;;
			battery)
				battery="${cmd[@]:1}"
				if [ $battery == "off" ] ; then
					battery=""
				else
					battery="$battery $separator%{B-} "
				fi
				;;
            date)
                #echo "resetting date" >&2
                date="${cmd[@]:1}"
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
        esac
    done
} 2> /dev/null | bar $bar_opts | {
	#Handle clickable areas
	while read line; do
		IFS=',' read -a c <<< $(echo $line)
		case "${c[0]}" in
			tag)
				herbstclient use "${c[1]}"
				echo "herbstclient use \"${c[1]}\""
				;;
			*)
				echo "${c[0]}: not valid command"
				;;
		esac
	done
}
