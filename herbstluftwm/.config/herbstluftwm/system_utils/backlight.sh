#!/usr/bin/env bash

hlwm_utils_backlight() {
    printf "%.0f" $(xbacklight -get)
}

# vim: set ts=8 sw=4 tw=0 et :
