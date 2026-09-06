# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="twig"
PKG_VERSION="6343ba99dd33ef8789f7724c1c574b076969e0eb"
PKG_LICENSE="Public Domain"
PKG_SITE="https://github.com/spruceUI/spruceOS/"
PKG_URL="https://github.com/spruceUI/spruceOS/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 emulators systemd"
PKG_LONGDESC="twigUI SD card package"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p "${PKG_BUILD}/spruce"
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C "${PKG_BUILD}/spruce"
}

copy_emulators() {
  jsonf=$(cat "${PKG_DIR}"/install/emulators.json)

  while read -r jvalue
  do
    package=$(echo "$jvalue" | jq -r '.package')

    for file in $(echo "$jvalue" | jq -c '.files[]')
    do
      src=$(echo "$file" | jq -r '.src')
      dest=$(echo "$file" | jq -r '.dest')
      build_dir="$(get_build_dir $package)"

      cp -f "$build_dir"/"$src" "${SPRUCE_DIR}"/"$dest"
    done

  done < <(echo "$jsonf" | jq -c '.emulators[]')
}

make_target() {
  SPRUCE_DIR="${PKG_BUILD}/spruce"

  # Copy new files
  cp -rf ${PKG_DIR}/install/SDCARD/* "${SPRUCE_DIR}"

  # Remove uneeded files for other devices
  shopt -s extglob
  for f in $(cat ${PKG_DIR}/install/delete.txt) ; do
    rm -rf "${SPRUCE_DIR}"/$f
  done

  copy_emulators

  if [ "$RELEASE" = "true" ]; then
    # Remove developer_mode flag if needed
    rm "${SPRUCE_DIR}"/spruce/flags/developer_mode

    # Download themes
    wget -nc -P ${SPRUCE_DIR}/Themes/ -i ${PKG_DIR}/install/themes.txt
  fi

  # Adjust default configs
  CONF_FILE="${SPRUCE_DIR}/Saves/spruce/spruce-config.json"

  cat "${CONF_FILE}" | jq '.menuOptions."System Settings".useZRAM.selected = "True"' | tee "${CONF_FILE}"
  cat "${CONF_FILE}" | jq '.menuOptions."Battery Settings".idlemonChargingInMenu.selected = "30s"' | tee "${CONF_FILE}"
  cat "${CONF_FILE}" | jq '.menuOptions."Battery Settings".shutdownFromSleep.selected = "Off"' | tee "${CONF_FILE}"

  # TODO: Check if this is needed
  PS_CONF="${SPRUCE_DIR}/Emu/PS/config.json"
  cat "${PS_CONF}" | jq '.menuOptions.Governor.selected = "Performance"' | tee "${PS_CONF}"

  # Create spruce 7z file
  ARCHIVE_FILE=${PKG_BUILD}/twigUI_SDCARD.7z
  7z a -t7z -mx=7 -mf- "${ARCHIVE_FILE}" "${SPRUCE_DIR}"/. > /dev/null

  # Copy version file and boot logo
  cp -f "${PKG_DIR}"/install/logo.bmp ${PKG_BUILD}/
  cp -f "${SPRUCE_DIR}"/spruce/twig ${PKG_BUILD}/version
  rm -rf "${SPRUCE_DIR}"
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

post_install() {
  add_user spruce x 0 0 "Root User" "/mnt/SDCARD" "/bin/sh"
  enable_service twig-splash.service
}