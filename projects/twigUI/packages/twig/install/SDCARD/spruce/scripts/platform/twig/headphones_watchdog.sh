#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

PLAYBACK_PATH="Playback Path"
PLAYBACK_PATH_SPK="SPK"
PLAYBACK_PATH_HP="HP"
EVENT_PATH="/dev/input/by-path/platform-rk817-sound-event"

# Initial value at boot, 0 = connected
if evtest --query "${EVENT_PATH}" EV_SW SW_HEADPHONE_INSERT ; then
    amixer -c0 sset "${PLAYBACK_PATH}" "${PLAYBACK_PATH_HP}"
else
    amixer -c0 sset "${PLAYBACK_PATH}" "${PLAYBACK_PATH_SPK}"
fi

# Actual watchdog
evtest "${EVENT_PATH}" | while read line; do
    case $line in
        *"SW_HEADPHONE_INSERT), value 0")
            amixer -c0 sset "${PLAYBACK_PATH}" "${PLAYBACK_PATH_HP}"
            ;;
        *"SW_HEADPHONE_INSERT), value 1")
            amixer -c0 sset "${PLAYBACK_PATH}" "${PLAYBACK_PATH_SPK}"
            ;;
    esac

    # Sync volume
    VOLUME_LV=$(get_volume_level)
    set_volume "$(( VOLUME_LV ))"
done
