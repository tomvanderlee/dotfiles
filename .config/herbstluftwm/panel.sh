#!/bin/bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}

add_alpha_channel(){
	echo "$1" | \
	sed "s/.*#\([0-9a-fA-F]*\).*/#ff\1/"
}

panel_height=$2
light=$(add_alpha_channel $3)
llight=$(add_alpha_channel $4)
accent=$(add_alpha_channel $5)
ldark=$(add_alpha_channel $6)
dark=$(add_alpha_channel $7)

font="-*-fixed-medium-*-*-*-14-*-*-*-*-*-*-*"
#font=""
selected_bg=$accent
normal_bg=$dark
selected_txt=$dark
normal_txt=$light
inactive_txt=$llight

hc pad $monitor $panel_height

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
				grep Front\
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
			echo -e "wireless\toff"
		else
			ssid=$(\
				echo $iwconfig | \
				sed "s/.*ESSID:\(\".*\"\).*/\1/" | \
				sed "s/.*\(off\/any\).*/\"\1\"/" | \
				sed "s/.*\"\(.*\)\".*/\1/"\
			)
			if [ $ssid = "off/any" ] ; then
				ifconf=$
				echo -e "wireless\t%{F$normal_txt}Wlan: No connection%{F-}"
			else	
				IFS=',' read -a quality_info <<< $(\ 
					echo $iwconfig | \
					sed "s/.*Link Quality=\([0-9]*\)\/\([0-9]*\).*/\1,\2/"\ 
				)
				cur_qual=${quality_info[0]}
				max_qual=${quality_info[1]}
				quality_p=$(echo "$cur_qual*100/$max_qual" | bc)
				echo -e "wireless\t%{F$normal_txt}Wlan: $quality_p%% %{F$inactive_txt}($ssid)%{F-}"
			fi
		fi
			
		# Battery
		IFS=' ' read -a batinfo <<< $(acpi -b)
		if [ -z $batinfo ] ; then
			echo -e "battery\toff"
		else 
		charge=$(echo ${batinfo[3]} | tr -d '%,')
			if [ $charge -lt 15 ] ;	then
				bat_color=$accent
			else
				bat_color=$normal_txt
			fi
			state=$(echo ${batinfo[2]} | tr -d ',')
			remaining=$(echo ${batinfo[4]})
			echo -e "battery\t%{F$normal_txt}$state: %{F$bat_color}$charge%{F$normal_txt}%% %{F$inactive_txt}($remaining)%{F-}"
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
	wireless=""
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
            echo -n " ${i:1} %{F-}%{B-}%{U-u}"
        done
        echo -n "$separator"
        echo -n "%{B-}%{F-} ${windowtitle//^/^^}"
        
		#Right part of panel
        right="$volume$wireless$battery$date "
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
			wireless)
				wireless="${cmd[@]:1}"
				if [ $wireless = "off" ] ; then
					wireless=""
				else
					wireless="$wireless $separator%{B-} "
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
} 2> /dev/null | bar -g $panel_width\x$panel_height\+$x+$y -f "$font" \
    -u 2 -B "$normal_bg" -F "$normal_txt"
