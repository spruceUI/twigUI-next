#!/bin/bash

. /etc/profile

mount -o "rw,noatime" LABEL=TWIGUI /mnt/SDCARD

if [ -f "/flash/first_run.txt" ]; then
    /usr/bin/install_spruce.sh
else
    if [ -f "/mnt/SDCARD/.tmp_update/updater" ]; then
        /mnt/SDCARD/.tmp_update/updater
    else
        sleep 5
        show_msg 640 480 "Empty image.| |Device will power off in 30s." &
        sleep 30

        pkill show_msg
        poweroff
    fi
fi

exit 0