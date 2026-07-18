# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="cava"
PKG_VERSION="1.0.0"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/karlstav/cava"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain fftw pipewire iniparser"
PKG_LONGDESC="Cross-platform Audio Visualizer."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET+=" --disable-output-ncurses --disable-cava-font --disable-output-sdl"

pre_configure_target() {
  cd ${PKG_BUILD}
  ./autogen.sh
}

post_configure_target() {
  sed -i "s|-I/usr/include/iniparser|-I${SYSROOT_PREFIX}/usr/include/iniparser|" ${PKG_BUILD}/Makefile
  sed -i "s|-DLEGACYINIPARSER||" ${PKG_BUILD}/Makefile
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/cava
  cp -f ${PKG_DIR}/config/config ${INSTALL}/usr/config/cava/config
}