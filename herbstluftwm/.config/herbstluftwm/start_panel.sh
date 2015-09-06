#!/usr/bin/env bash

source "$HLWM_CONF_DIR/panel_indicators.sh"

# Check for valid monitors
monitor=${1:-0}
geometry=($(herbstclient monitor_rect "$monitor"))
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi

monitor_x=${geometry[0]}
monitor_y=${geometry[1]}
monitor_w=${geometry[2]}
monitor_h=${geometry[3]}

# Make sure only one instanve per monitor is running
pids=$(ps x | grep "$0 $monitor" | awk '{print $1}')
for pid in $pids; do
    if [ $pid != $$ ]; then
        pkill -P $pid
    fi
done

padding=(0 0 0 0)

if [ -n "$HLWM_PANEL_MARGIN" ]; then
    margins=($HLWM_PANEL_MARGIN)
    panel_td_margin=$([ ${margins[0]} -eq -1 ] && echo $HLWM_WINDOW_PADDING || echo ${margins[0]})
    panel_lr_margin=$([ ${margins[1]} -eq -1 ] && echo $HLWM_WINDOW_PADDING || echo ${margins[1]})
else
    panel_td_margin=$HLWM_WINDOW_PADDING
    panel_lr_margin=$HLWM_WINDOW_PADDING
fi

x=$(echo "$monitor_x + $panel_lr_margin" | bc)
panel_width=$(echo "$monitor_w - (2 * $panel_lr_margin)" | bc)

if $HLWM_PANEL_BOTTOM; then
    y=$(echo "$monitor_h - $HLWM_PANEL_HEIGHT - $panel_td_margin" | bc)
    padding[2]=$(echo "$HLWM_PANEL_HEIGHT + $panel_td_margin" | bc)
else
    y=$(echo "$monitor_y + $panel_td_margin" | bc)
    padding[0]=$(echo "$HLWM_PANEL_HEIGHT + $panel_td_margin" | bc)
fi

# Apply padding to make room for the panel
hc pad $monitor ${padding[@]}

# Start the panel
$HLWM_CONF_DIR/populate_panel.sh $monitor |
lemonbar -g ${panel_width}x${HLWM_PANEL_HEIGHT}+${x}+${y} -f "$HLWM_PANEL_FONT" -f "$icon_font" -u2 -B$HLWM_BG_ACOLOR -F$HLWM_FG_ACOLOR |
$HLWM_CONF_DIR/panel_handler.sh

# vim: set ts=4 sw=4 tw=0 et :
