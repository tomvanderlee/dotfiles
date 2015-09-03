#!/usr/bin/env bash

source "$HLWM_CONF_DIR/panel_indicators.sh"

# Check for valid monitors
monitor=${1:-0}
geometry=($(herbstclient monitor_rect "$monitor"))
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi

# Make sure only one instanve per monitor is running
pids=$(ps x | grep "$0 $monitor" | awk '{print $1}')
for pid in $pids; do
    if [ $pid != $$ ]; then
        pkill -P $pid
    fi
done

# Geometry has the format W H X Y
x=$(echo "${geometry[0]} + $HLWM_WINDOW_PADDING" | bc)
y=$(echo "${geometry[1]} + $HLWM_WINDOW_PADDING" | bc)
panel_width=$(echo "${geometry[2]} - (2 * $HLWM_WINDOW_PADDING)" | bc)

# Apply padding to make room for the panel
hc pad $monitor $(echo "$HLWM_PANEL_HEIGHT + $HLWM_WINDOW_PADDING" | bc)

# Start the panel
$HLWM_CONF_DIR/populate_panel.sh $monitor |
lemonbar -g ${panel_width}x${HLWM_PANEL_HEIGHT}+${x}+${y} -f "$HLWM_PANEL_FONT" -f "$icon_font" -u2 -B$HLWM_BG_ACOLOR -F$HLWM_FG_ACOLOR |
$HLWM_CONF_DIR/panel_handler.sh

# vim: set ts=4 sw=4 tw=0 et :
