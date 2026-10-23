# SPDX-License-Identifier: GPL-2.0

PKG_NAME="usb-adb"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain android-tools"
PKG_LONGDESC="adb on the GKD Pixel 2's USB-C port whenever a computer is on the cable"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/usb-adb ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/usb-adb
}

post_install() {
  enable_service usb-adb.service
}
