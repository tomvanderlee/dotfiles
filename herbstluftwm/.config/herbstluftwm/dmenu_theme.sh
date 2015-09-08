#!/bin/sh

theme_dir="$HLWM_CONF_DIR/themes"
themes=$(ls "$theme_dir" | grep -vE "current|template")
theme=$(echo "$themes" | dmenu "$@")

if [ -n "$theme" ] && [ -f "$theme_dir/$theme" ]; then
	ln -sf "$theme" "$theme_dir/current" && herbstclient reload
fi

