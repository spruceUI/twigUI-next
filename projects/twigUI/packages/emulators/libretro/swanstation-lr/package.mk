# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Maintenance 2020 351ELEC team (https://github.com/fewtarius/351ELEC)

PKG_NAME="swanstation-lr"
PKG_VERSION="f901022198dacf125d43331c6540492441ab415b"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/swanstation"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host core-info"
PKG_LONGDESC="SwanStation - PlayStation 1, aka. PSX Emulator"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-lto"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_configure_target() {
 PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRETRO_CORE=ON "
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/swanstation_libretro.info "${PKG_BUILD}"/
  LR_SO="${PKG_BUILD}"/.${TARGET_NAME}/swanstation_libretro.so

  ${STRIP} "${LR_SO}"
  cp "${LR_SO}" "${PKG_BUILD}"/
}
