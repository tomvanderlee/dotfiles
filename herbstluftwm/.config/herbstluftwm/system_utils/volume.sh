#!/usr/bin/env bash

hlwm_utils_volume() {
    amixer get Master |
    grep "Front Right: Playback" |
    sed "s/.*\[\([0-9]*\)%\].*/\1/"
}
# vim: set ts=8 sw=4 tw=0 et :
