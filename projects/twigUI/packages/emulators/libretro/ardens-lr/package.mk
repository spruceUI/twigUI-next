# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ardens-lr"
PKG_VERSION="2376f7dfa9fb21b96763084b3b72ac6d4840e90c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/tiberiusbrown/Ardens"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A simulator for the Arduboy FX that can be used for profiling and debugging."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DARDENS_LLVM=0 \
                           -DARDENS_DEBUGGER=0 \
                           -DARDENS_PLAYER=0 \
                           -DARDENS_LIBRETRO=1 \
                           -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE"
}

makeinstall_target() {
  LR_SO="${PKG_BUILD}"/.${TARGET_NAME}/ardens_libretro.so

  ${STRIP} "${LR_SO}"

  cp "${LR_SO}" "${PKG_BUILD}"/
  cp "${PKG_BUILD}"/src/libretro_core/ardens_libretro.info "${PKG_BUILD}"/
}
