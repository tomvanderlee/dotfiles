#!/bin/sh

theme_dir="$HLWM_CONF_DIR/themes"
current=$(readlink "$theme_dir/current")
themes=$(ls "$theme_dir" | grep -vE "^current|template|README\.md|$current\$")
theme=$(echo "$themes" | rofi -dmenu -p "theme:" $@)

if [ -n "$theme" ] && [ -f "$theme_dir/$theme" ]; then
	ln -sf "$theme" "$theme_dir/current" && herbstclient reload
fi

