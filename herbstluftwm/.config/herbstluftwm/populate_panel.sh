#!/usr/bin/env bash

source "$HLWM_CONF_DIR/panel_indicators.sh"
monitor=$1

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
        music
        volume &
        network &
        battery &
        clock &
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

    separator="%{F$HLWM_ACCENT_ACOLOR}|%{F-}"

    while true ; do

        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "%{U$HLWM_ACCENT_ACOLOR+u}%{F$HLWM_FG_ACOLOR}"
                    ;;
                '+')
                    echo -n "%{U$HLWM_FG_ACOLOR+u}%{F$HLWM_FG_ACOLOR}"
                    ;;
                ':')
                    echo -n "%{F$HLWM_FG_ACOLOR}"
                    ;;
                '!')
                    echo -n "%{B$HLWM_ACCENT_ACOLOR}%{U$HLWM_ACCENT_ACOLOR+u}%{F$HLWM_BG_ACOLOR}"
                    ;;
                *)
                    echo -n "%{F$HLWM_FG_ACOLOR}"
                    ;;
            esac
            echo -n "%{A:tag,${i:1}:} ${i:1} %{A}%{F-}%{U-u}%{B-}"
        done

        echo -n "$separator%{F-}%{B-} "
        echo -n "${windowtitle//^/^^}"

       # Right part of panel
        right="$music$volume$net$battery$date "
        echo -n "%{r}$right"

        #DO NOT REMOVE THIS ECHO
        echo

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            music)
                music="${cmd[@]:1}"
                if [ $music == "off" ] ; then
                    music=""
                else
                    music="$music $separator%{B-} "
                fi
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

} 2> /dev/null

# vim: set ts=4 sw=4 tw=0 et :
