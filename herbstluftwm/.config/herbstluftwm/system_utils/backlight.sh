#!/usr/bin/env bash

hlwm_utils_backlight() {
    value=$(xbacklight -get)

    [ -n "$value" ] && printf "%.0f" $value
}

# vim: set ts=8 sw=4 tw=0 et :
