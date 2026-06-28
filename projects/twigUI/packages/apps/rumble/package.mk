# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rumble"
PKG_VERSION="v1.0"
PKG_LICENSE="LGPL-2.1"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Very simple test tool for vibrator strength"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  cp -f ${PKG_DIR}/rumble.c ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/rumble ${INSTALL}/usr/bin
}
