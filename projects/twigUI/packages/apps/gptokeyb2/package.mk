# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gptokeyb2"
PKG_VERSION="2026.02.28-2309"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/PortsMaster/gptokeyb2"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/gptokeyb2-all.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="GamePad TO Key Board v2"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  cd "${PKG_BUILD}"
  unzip "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  install -Dm755 ${PKG_BUILD}/gptokeyb2 ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
  cp -rf ${PKG_BUILD}/libinterpose.aarch64.so ${INSTALL}/usr/lib
}
