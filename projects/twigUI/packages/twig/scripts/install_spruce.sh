#!/bin/sh

mount -o remount,rw /flash

LOG=/flash/fs-resize.log
date -Iseconds >> $LOG

MSG1="Expanding SD card..."
MSG2="Installing system...| |This might take several minutes|depending on the SD card speed.| |The device will reboot once the process is over."

sleep 5
# -------------------------------- Expand last partition
show_msg 640 480 "${MSG1}" &
sleep 2

# Get partition info
echo "INFO:" >> $LOG
echo $(grep "/mnt/SDCARD " /proc/mounts) >> $LOG 2>&1

PART="/dev/mmcblk0p3"
DISK=$(echo $PART | sed s/p[0-9]$//g)
END=$(parted -m $DISK print | grep "ext4" | cut -d":" -f3)

# Start process
echo "DISK: $DISK  PART: $PART  END: $END" >> $LOG

echo "Creating partition..." >> $LOG
parted -s -f -m $DISK mkpart primary fat32 $END 100% >> $LOG 2>&1

echo "Formatting partition to FAT32..." >> $LOG
mkfs.fat -F32 -n TWIGUI $PART >> $LOG 2>&1

echo "Syncing..." >> $LOG 2>&1
sync

pkill show_msg

# -------------------------------- Extract .7z
show_msg 640 480 "${MSG2}" &

echo "Mounting filesystem..." >> $LOG
mount -o "rw,noatime" LABEL=TWIGUI /mnt/SDCARD

echo "Extracting install file..." >> $LOG
7zr x -o/mnt/SDCARD/ /flash/twigUI_SDCARD.7z >> $LOG 2>&1

echo "Cleaning up install file..." >> $LOG
rm /flash/twigUI_SDCARD.7z

# -------------------------------- Cleanup
echo "Done." >> $LOG
rm /flash/first_run.txt
mount -o remount,ro /flash

sync
pkill show_msg
reboot
