#!/bin/bash
# Will be called by PortMaster mod_ROCKNIX.txt

. /etc/profile

if echo "${UI_SERVICE}" | grep -q "sway"; then
    # Call the function to fullscreen the window for app_id asynchronously
    sway_fullscreen "${1}" &
fi
