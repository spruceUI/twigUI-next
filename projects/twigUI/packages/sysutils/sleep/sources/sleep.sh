#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

if [ -e "/sys/firmware/devicetree/base/model" ]; then
  QUIRK_DEVICE=$(tr -d '\0' </sys/firmware/devicetree/base/model 2>/dev/null)
fi
QUIRK_DEVICE="$(echo ${QUIRK_DEVICE} | sed -e "s#[/]#-#g")"

EVENTLOG="/var/log/sleep.log"

modules() {
  log $0 "Modules: ${1}"
  case ${1} in
    stop)
      if [ -e "/usr/config/modules.bad" ]; then
        for module in $(cat /usr/config/modules.bad); do
          EXISTS=$(lsmod | grep ${module})
          if [ $? = 0 ]; then
            echo ${module} >>/tmp/modules.load
            modprobe -r ${module} >${EVENTLOG} 2>&1
          fi
        done
      fi
      ;;
    start)
      if [ -e "/tmp/modules.load" ]; then
        for module in $(cat /tmp/modules.load); do
          MODCNT=0
          MODATTEMPTS=10
          while true; do
            if (( "${MODCNT}" < "${MODATTEMPTS}" )); then
              modprobe ${module%% *} >${EVENTLOG} 2>&1
              if [ $? = 0 ]; then
                break
              fi
            else
              break
            fi
            MODCNT=$((${MODCNT} + 1))
            sleep .5
          done
        done
        rm -f /tmp/modules.load
      fi
      ;;
  esac
}

quirks() {
  for QUIRK in /usr/lib/autostart/quirks/platforms/"${HW_DEVICE}"/sleep.d/${1}/* \
               /usr/lib/autostart/quirks/devices/"${QUIRK_DEVICE}"/sleep.d/${1}/*; do
    "${QUIRK}" >${EVENTLOG} 2>&1
  done
}

case $1 in
  pre)
    modules stop
    quirks pre
    touch /run/.last_sleep_time
    ;;
  post)
    modules start
    quirks post
    ;;
esac
