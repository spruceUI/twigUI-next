# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="rocknix"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain autostart"
PKG_LONGDESC="ROCKNIX Meta Package"
PKG_TOOLCHAIN="make"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/

  ### Compatibility links for ports
  ln -s /storage/roms ${INSTALL}/roms

  ### Add some quality of life customizations for hardworking devs.
  if [ -n "${LOCAL_SSH_KEYS_FILE}" ]
  then
    mkdir -p ${INSTALL}/usr/config/ssh
    cp ${LOCAL_SSH_KEYS_FILE} ${INSTALL}/usr/config/ssh/authorized_keys
  fi

  # Always install the update script
  mkdir -p $INSTALL/usr/share/bootloader
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
}

post_install() {
  ln -sf rocknix.target ${INSTALL}/usr/lib/systemd/system/default.target

  if [ ! -d "${INSTALL}/usr/share" ]
  then
    mkdir "${INSTALL}/usr/share"
  fi

  # Issue banner
  cat <<EOF >> ${INSTALL}/etc/issue
... Version: ${OS_VERSION} (${OS_BUILD})
... Built: ${BUILD_DATE}

EOF
  cp ${PKG_DIR}/sources/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/* 2>/dev/null ||:

  ### Fix and migrate to autostart package
  enable_service rocknix-autostart.service

  ### ZRAM/Swap and Memory Manager Service
  enable_service rocknix-memory-manager.service
}
