# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="armgba-lr"
PKG_VERSION="9847d41da663ebee7839874c34ebde26f0df1e03"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Jacob-Matthew-Cook/armGBA"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="armGBA is a Game Boy Advance, Game Boy and Game Boy Color emulator built around a recompiler for ARM and x86 handhelds."
PKG_TOOLCHAIN="cmake"

makeinstall_target() {
  ${STRIP} "${PKG_BUILD}"/.${TARGET_NAME}/armgba_libretro.so
  cp "${PKG_BUILD}"/.${TARGET_NAME}/armgba_libretro.so "${PKG_BUILD}"/

  cp "${PKG_BUILD}"/libretro/armgba_libretro.info "${PKG_BUILD}"/
}