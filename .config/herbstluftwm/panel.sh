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

panel_height=$2
light=$3
llight=$4
accent=$5
ldark=$6
dark=$7

font="-*-fixed-medium-*-*-*-14-*-*-*-*-*-*-*"
#font=""
selected_bg=$accent
normal_bg=$dark
selected_txt=$dark
normal_txt=$light
inactive_txt=$llight

########################################################################################
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if which textwidth &> /dev/null ; then
    textwidth="textwidth";
elif which dzen2-textwidth &> /dev/null ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi

########################################################################################
# true if we are using the svn version of dzen2
# depending on version/distribution, this seems to have version strings like
# "dzen-" or "dzen-x.x.x-svn"
if dzen2 -v 2>&1 | head -n 1 | grep -q '^dzen-\([^,]*-svn\|\),'; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

########################################################################################
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

########################################################################################
hc pad $monitor $panel_height

########################################################################################
{
    ### Event generator ###
    # based on different input data (mpc, date, hlwm hooks, ...) this generates events, formed like this:
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29

    while true ; do
		# Volume
		volumes=$(\
			amixer get Master | \
			grep Front\
		)
		vol=$(\
			echo $volumes | \
			sed "s/.*\[\([0-9]*\)%\].*/\1/"\
		)
		if [ -z $vol ] ; then
			echo -e "volume\t^fg($normax_txt)Audio off"
		elif [ $vol -le 0 ] ; then
			echo -e "volume\t^fg($normal_txt)Volume muted"
		else
			echo -e "volume\t^fg($normal_txt)Volume: $vol%"
		fi

		# Network
		iwconfig=$(iwconfig wlp3s0)
		ssid=$(\
			echo $iwconfig | \
			sed "s/.*ESSID:\(\".*\"\).*/\1/" | \
			sed "s/.*\(off\/any\).*/\"\1\"/" | \
			sed "s/.*\"\(.*\)\".*/\1/"\
		)
		if [ $ssid = "off/any" ] ; then
			echo -e "wireless\t^fg($normal_txt)Wlan: No connection"
		else	
			IFS=',' read -a quality_info <<< $(\ 
				echo $iwconfig | \
				sed "s/.*Link Quality=\([0-9]*\)\/\([0-9]*\).*/\1,\2/"\ 
			)
			cur_qual=${quality_info[0]}
			max_qual=${quality_info[1]}
			quality_p=$(echo "$cur_qual*100/$max_qual" | bc)
			echo -e "wireless\t^fg($normal_txt)Wlan: $quality_p% ^fg($inactive_txt)($ssid)"
		fi
			
		# Battery
		IFS=' ' read -a batinfo <<< $(acpi -b)
		if [ -z $batinfo ] ; then
			echo -e "battery\t^fg($normax_txt)No battery"
		else 
		charge=$(echo ${batinfo[3]} | tr -d '%,')
			if [ $charge -lt 15 ] ;	then
				bat_color=$accent
			else
				bat_color=$normal_txt
			fi
			state=$(echo ${batinfo[2]} | tr -d ',')
			remaining=$(echo ${batinfo[4]})
			echo -e "battery\t^fg($normal_txt)$state: ^fg($bat_color)$charge^fg($normal_txt)% ^fg($inactive_txt)($remaining)"
		fi

		# Time
        echo -e $(date +$"date\t^fg($normal_txt)%H:%M:%S^fg($inactive_txt) (%d-%m-%Y)")
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

        ### Output ######################################################################
        # This part prints dzen data based on the _previous_ data handling run,
        # and then waits for the next event to happen.

        bordercolor="#26221C"
        separator="^bg()^fg($accent)|"
        # draw tags
        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^bg($selected_bg)^fg($selected_txt)"
                    ;;
                '+')
                    echo -n "^bg($accent)^fg($normal_bg)"
                    ;;
                ':')
                    echo -n "^bg()^fg($normal_txt)"
                    ;;
                '!')
                    echo -n "^bg($normal_txt)^fg($normal_bg)"
                    ;;
                *)
                    echo -n "^bg()^fg($inactive_txt)"
                    ;;
            esac
            if [ ! -z "$dzen2_svn" ] ; then
                # clickable tags if using SVN dzen
                echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "focus_monitor \"$monitor\" && "
                echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "use \"${i:1}\") ${i:1} ^ca()"
            else
                # non-clickable tags if using older dzen
                echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        echo -n "^bg()^fg() ${windowtitle//^/^^}"
        # small adjustments
        right="$volume $separator^bg() $wireless $separator^bg() $battery $separator^bg() $date "
        right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$($textwidth "$font" "$right_text_only")
        echo -n "^pa($(($panel_width - $width)))$right"
        echo

        ### Data handling ###
        # This part handles the events generated in the event loop, and sets
        # internal variables based on them. The event and its arguments are
        # read into the array cmd, then action is taken depending on the event
        # name.
        # "Special" events (quit_panel/togglehidepanel/reload) are also handled
        # here.

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
			volume)
				volume="${cmd[@]:1}"
				;;
			wireless)
				wireless="${cmd[@]:1}"
				;;
			battery)
				battery="${cmd[@]:1}"
				;;
            date)
                #echo "resetting date" >&2
                date="${cmd[@]:1}"
                ;;
            quit_panel)
                exit
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $panel_height
                fi
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            #player)
            #    ;;
        esac
    done

    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.

} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
    -ta l -bg "$normal_bg" -fg "$normal_txt"
