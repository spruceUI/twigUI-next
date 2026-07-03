# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="neocd-lr"
PKG_VERSION="9e9ad181bed60f84f9cff02c03617b41e8a31cfe"
PKG_LICENSE="LGPLv3.0"
PKG_SITE="https://github.com/libretro/neocd_libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain flac libogg libvorbis"
PKG_LONGDESC="Neo Geo CD emulator for libretro "
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  cd ${PKG_BUILD}
  CFLAGS=${CFLAGS} CXXFLAGS="${CXXFLAGS}" CXX="${CXX}" CC="${CC}" LD="$LD" RANLIB="$RANLIB" AR="${AR}" make
}

makeinstall_target() {
  ${STRIP} "${PKG_BUILD}"/neocd_libretro.so
  cp "${PKG_BUILD}"/retroarch/libneocd_libretro.info "${PKG_BUILD}"/neocd_libretro.info
}
