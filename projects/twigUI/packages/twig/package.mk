# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="twig"
PKG_VERSION="259c5b5d9e788418f7264542413e5f9623e47970"
PKG_LICENSE="Public Domain"
PKG_SITE="https://github.com/spruceUI/spruceOS/"
PKG_URL="https://github.com/spruceUI/spruceOS/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="twigUI SD card package"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p "${PKG_BUILD}/spruce"
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C "${PKG_BUILD}/spruce"
}

make_target() {
  SPRUCE_DIR="${PKG_BUILD}/spruce"

  # Copy new files
  cp -rf ${PKG_DIR}/install/SDCARD/* "${SPRUCE_DIR}"

  # Remove uneeded files for other devices
  shopt -s extglob
  for f in $(cat ${PKG_DIR}/install/delete.txt) ; do
    rm -r "${SPRUCE_DIR}"/$f
  done

  # Adjust default configs
  CONF_FILE="${SPRUCE_DIR}/Saves/spruce/spruce-config.json"

  cat "${CONF_FILE}" | jq '.menuOptions."System Settings".useZRAM.selected = "True"' | tee "${CONF_FILE}"
  cat "${CONF_FILE}" | jq '.menuOptions."Battery Settings".idlemonChargingInMenu.selected = "30s"' | tee "${CONF_FILE}"
  cat "${CONF_FILE}" | jq '.menuOptions."Battery Settings".shutdownFromSleep.selected = "Off"' | tee "${CONF_FILE}"

  # TODO: Check if this is needed
  PS_CONF="${SPRUCE_DIR}/Emu/PS/config.json"
  cat "${PS_CONF}" | jq '.menuOptions.Governor.selected = "Performance"' | tee "${PS_CONF}"

  # TODO: developer_mode flag
  ARCHIVE_FILE=${PKG_BUILD}/twigUI_V"$(cat ${SPRUCE_DIR}/spruce/twig)".7z
  7z a -t7z -mx=7 -mf- "${ARCHIVE_FILE}" "${SPRUCE_DIR}"/.
}

makeinstall_target() {
  mkdir -p ${INSTALL}/mnt/SDCARD
  touch ${INSTALL}/mnt/SDCARD/.empty

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/start_spruce.sh ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/install_spruce.sh ${INSTALL}/usr/bin

  chmod 0755 ${INSTALL}/usr/bin/start_spruce.sh
  chmod 0755 ${INSTALL}/usr/bin/install_spruce.sh

  ln -sf ${PKG_PYTHON_VERSION} ${INSTALL}/usr/bin/MainUI
}
