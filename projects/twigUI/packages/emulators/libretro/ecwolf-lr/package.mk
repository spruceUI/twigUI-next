# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ecwolf-lr"
PKG_VERSION="4731f0075d6c225921b40b341b23971e73dd9dfc"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/ecwolf"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_net libjpeg-turbo bzip2 core-info"
PKG_LONGDESC="ECWolf is a port of the Wolfenstein 3D engine based of Wolf4SDL."
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_MAKE_OPTS_TARGET="-C src/libretro"

pre_configure_target() {
  CXXFLAGS="${CXXFLAGS} -Wno-error=int-conversion"
}

pre_make_target() {
  cd ${PKG_BUILD}
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/ecwolf_libretro.info "${PKG_BUILD}"/
  LR_SO="${PKG_BUILD}"/src/libretro/ecwolf_libretro.so

  ${STRIP} "${LR_SO}"
  cp "${LR_SO}" "${PKG_BUILD}"/
}
