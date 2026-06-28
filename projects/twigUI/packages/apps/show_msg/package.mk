# SPDX-License-Identifier: GPL-2.0

PKG_NAME="show_msg"
PKG_VERSION="v1.0"
PKG_LICENSE="Public Domain"
PKG_DEPENDS_TARGET="toolchain sdl12-compat SDL_ttf"
PKG_LONGDESC="Simple tool to show text using SDL."
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  cp -f ${PKG_DIR}/show_msg.c ${PKG_BUILD}
  export GCC_OPTS=" -I${SYSROOT_PREFIX}/usr/include/SDL -D_REENTRANT"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/show_msg ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/fonts/
  cp ${PKG_DIR}/nunwen.ttf ${INSTALL}/usr/share/fonts/nunwen.ttf
}
