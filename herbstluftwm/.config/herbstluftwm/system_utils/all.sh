#!/usr/bin/env bash
utils=$(find "$HLWM_CONF_DIR/system_utils/" -name "*.sh" | grep -v ".*all.sh")

for util in $utils; do
    echo "source $util"
    source $util
done

# vim: set ts=8 sw=4 tw=0 et :
