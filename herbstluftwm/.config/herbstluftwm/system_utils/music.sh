#!/usr/bin/env bash

hlwm_utils_music_playing() {
    playing=""

    mpd_status=$(mpc | sed -nr "s/^\[(.*)\].*$/\1/p")
    if [ "$mpd_status" = "playing" ]; then
        player_artist=$(mpc -f "%artist%" current)
        player_title=$(mpc -f "%title%" current)
        if [ -n "$player_artist" ]; then
            playing="$player_artist - $player_title"
        else
            playing="$player_title"
        fi
    elif [ "$(playerctl status)" = "Playing" ]; then
        player_artist=$(playerctl metadata artist)
        player_title=$(playerctl metadata title)
        if [ -n "$player_artist" ] && [ -n "$player_title" ]; then
            playing="$player_artist - $player_title"
        else
            now_playing=$(playerctl metadata vlc:nowplaying)
            playing="$now_playing"
        fi
    fi

    echo "$playing"
}
# vim: set ts=8 sw=4 tw=0 et :
