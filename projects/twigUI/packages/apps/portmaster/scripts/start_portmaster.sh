#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release
set_kill set "PortMaster"

#Make sure PortMaster exists in .config/PortMaster
if [ ! -d "/storage/.config/PortMaster" ]; then
    mkdir -p "/storage/.config/PortMaster"
    cp -r "/usr/config/PortMaster" "/storage/.config/"
fi

# Make sure the symlink exists
if [ ! -L "/storage/roms/ports" ]; then
    mkdir -p /storage/roms
    ln -s /mnt/SDCARD/Roms/PORTS /storage/roms/ports
fi

cd /storage/.config/PortMaster

#Grab the latest control.txt & mapper.txt, then set correct permissions
cp /usr/config/PortMaster/control.txt control.txt
chmod +x /storage/.config/PortMaster/control.txt
cp /usr/config/PortMaster/mapper.txt mapper.txt
chmod +x /storage/.config/PortMaster/mapper.txt


#Use our gamecontrollerdb.txt
rm -r gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt gamecontrollerdb.txt

#Delete old PortMaster fold first (we can probably remove this later)
if [ ! -f "/mnt/SDCARD/Roms/PORTS/PortMaster/pugwash" ]; then
    rm -r /mnt/SDCARD/Roms/PORTS/PortMaster
fi

#Make sure /mnt/SDCARD/Roms/PORTS/PortMaster folder exists
if [ ! -d "/mnt/SDCARD/Roms/PORTS/PortMaster" ]; then
    unzip /usr/config/PortMaster/release/PortMaster.zip -d /mnt/SDCARD/Roms/PORTS/
    chmod +x /mnt/SDCARD/Roms/PORTS/PortMaster/PortMaster.sh

    # Install default theme
    if [ -d "/mnt/SDCARD/App/PortMaster/tmp" ]; then
        cp -rf /mnt/SDCARD/App/PortMaster/tmp/* /mnt/SDCARD/Roms/PORTS/PortMaster/
        rm -r /mnt/SDCARD/App/PortMaster/tmp/
    fi
fi

#We dont use tasksetter, delete it
if [ -f /mnt/SDCARD/Roms/PORTS/PortMaster/tasksetter ]; then
  rm -r /mnt/SDCARD/Roms/PORTS/PortMaster/tasksetter
fi

#Use PortMasters gptokeyb
rm gptokeyb
cp /mnt/SDCARD/Roms/PORTS/PortMaster/gptokeyb gptokeyb

#Copy over required files for ports
cp /storage/.config/PortMaster/control.txt /mnt/SDCARD/Roms/PORTS/PortMaster/control.txt
cp /storage/.config/PortMaster/mapper.txt /mnt/SDCARD/Roms/PORTS/PortMaster/mapper.txt
cp /storage/.config/PortMaster/gamecontrollerdb.txt /mnt/SDCARD/Roms/PORTS/PortMaster/gamecontrollerdb.txt
cp /usr/bin/oga_controls* /mnt/SDCARD/Roms/PORTS/PortMaster/

#Start PortMaster
cd /mnt/SDCARD/Roms/PORTS/PortMaster
./PortMaster.sh 2>/dev/null
