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
echo "INFO:" >> $LOG 2>&1
echo $(grep "/mnt/SDCARD " /proc/mounts) >> $LOG
PART=$(grep "/mnt/SDCARD " /proc/mounts | cut -d" " -f1 | grep '[0-9]$')
PARTNUM="${PART: -1}"
DISK=$(echo $PART | sed s/p[0-9]$//g)

# Start process
echo "DISK: $DISK  PART: $PART" >> $LOG

umount $PART
echo "Running parted..." >> $LOG 2>&1
parted -s -f -m $DISK resizepart $PARTNUM 100% >> $LOG 2>&1

echo "Running e2fsck..." >> $LOG 2>&1
e2fsck -f -p $PART >> $LOG 2>&1

echo "Running resize2fs..." >> $LOG 2>&1
resize2fs $PART >> $LOG 2>&1

echo "Running mkfs.exfat..." >> $LOG 2>&1
mkfs.exfat -n TWIGUI $PART >> $LOG 2>&1

echo "Syncing..." >> $LOG 2>&1

sync
pkill show_msg

# -------------------------------- Extract .7z
show_msg 640 480 "${MSG2}" &

echo "Mounting filesystem..." >> $LOG 2>&1
mount -o "rw,noatime" LABEL=TWIGUI /mnt/SDCARD

# echo "Moving install file..." >> $LOG 2>&1
# mv /flash/twigUI_V*.7z /mnt/SDCARD/

echo "Extracting install file..." >> $LOG 2>&1
7zr x -o/mnt/SDCARD/ /flash/twigUI_V*.7z >> $LOG 2>&1

echo "Cleaning up install file..." >> $LOG 2>&1
rm /flash/twigUI_V*.7z

# -------------------------------- Cleanup
echo "Done." >> $LOG 2>&1
rm /flash/first_run.txt
mount -o remount,ro /flash

sync
pkill show_msg
reboot
