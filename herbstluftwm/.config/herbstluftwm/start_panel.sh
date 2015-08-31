#!/usr/bin/env bash
source "$HLWM_CONF_DIR/themes/current"
source "$HLWM_CONF_DIR/panel_indicators.sh"

# Check for valid monitors
monitor=${1:-0}
geometry=($(herbstclient monitor_rect "$monitor"))
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi

# Make sure only one instanve per monitor is running
lockfile="/tmp/start_panel-$monitor.lck"
if [ -e "$lockfile" ] && kill -0 $(cat $lockfile); then
    pkill -P $(cat $lockfile)
fi
trap "rm -f $lockfile; exit" INT TERM EXIT
echo "$$" > "$lockfile"

# Geometry has the format W H X Y
x=$(echo "${geometry[0]} + $window_p" | bc)
y=$(echo "${geometry[1]} + $window_p" | bc)
panel_width=$(echo "${geometry[2]} - (2 * $window_p)" | bc)

# Apply padding to make room for the panel
hc pad $monitor $(echo "$panel_h + $window_p" | bc)

# Start the panel
$HLWM_CONF_DIR/populate_panel.sh $monitor |
lemonbar -g ${panel_width}x${panel_h}+${x}+${y} -f "$font" -f "$icon_font" -u2 -B$acolor_bg -F$acolor_fg |
$HLWM_CONF_DIR/panel_handler.sh

# vim: set ts=4 sw=4 tw=0 et :
