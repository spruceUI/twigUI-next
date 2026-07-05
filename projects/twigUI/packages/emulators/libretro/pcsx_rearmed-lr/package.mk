# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 Trond Haugland (trondah@gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="pcsx_rearmed-lr"
PKG_VERSION="050981b6eeb715f142854f57c68086f62921f027"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
  export CFLAGS="${CFLAGS} -flto -fipa-pta"
  export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta"
  export LDFLAGS="${LDFLAGS} -flto -fipa-pta"
}

make_target() {
  cd ${PKG_BUILD}
  make -f Makefile.libretro GIT_VERSION=${PKG_VERSION} platform=${DEVICE}
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/pcsx_rearmed_libretro.info "${PKG_BUILD}"/
  ${STRIP} "${PKG_BUILD}"/pcsx_rearmed_libretro.so
}
